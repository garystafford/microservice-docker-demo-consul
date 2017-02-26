#!/bin/sh

set -ex

# ##############################################################################
# Setup Docker Machine hosts for Docker swarm cluster
vms=( "manager1" "manager2" "manager3"
      "worker1" "worker2" "worker3" )

for vm in ${vms[@]}
do
  docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "1024" \
    --virtualbox-cpu-count "1" \
    --virtualbox-disk-size "20000" \
    --engine-label purpose=backend \
    ${vm}
done

docker-machine ls

# ##############################################################################

# http://www.thegeekstuff.com/2010/07/bash-string-manipulation/
# docker swarm leave --force
# rm -rf /var/lib/docker/swarm/*

SWARM_MANAGER_IP=$(docker-machine ip manager1)
echo ${SWARM_MANAGER_IP}
docker-machine ssh manager1 \
  "docker swarm init --advertise-addr \
  ${SWARM_MANAGER_IP}"

docker node ls

docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})

MANAGER_SWARM_JOIN=$(docker-machine ssh ${vms[0]} "docker swarm join-token manager") && \
  MANAGER_SWARM_JOIN=$(echo ${MANAGER_SWARM_JOIN} | grep -E "(docker).*(2377)" -o) && \
  MANAGER_SWARM_JOIN=$(echo ${MANAGER_SWARM_JOIN//\\/''})
echo ${MANAGER_SWARM_JOIN}

for vm in ${vms[@]:1:2}
do
  docker-machine ssh ${vm} ${MANAGER_SWARM_JOIN}
done

WORKER_SWARM_JOIN=$(docker-machine ssh manager1 "docker swarm join-token worker") && \
  WORKER_SWARM_JOIN=$(echo ${WORKER_SWARM_JOIN} | grep -E "(docker).*(2377)" -o) && \
  WORKER_SWARM_JOIN=$(echo ${WORKER_SWARM_JOIN//\\/''})
echo ${WORKER_SWARM_JOIN}

for vm in ${vms[@]:3:3}
do
  docker-machine ssh ${vm} ${WORKER_SWARM_JOIN}
done

docker node ls

# ##############################################################################

docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})
for vm in ${vms[@]:3:3}
do
  docker node update ${vm} --label-add app=true
done

docker node ls

# ##############################################################################

# https://github.com/hashicorp/consul/issues/1465
# https://github.com/hashicorp/consul/issues/725

# delete all containers
for vm in "${vms[@]}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f $(docker ps -a -q)
  docker network prune -f
  docker volume prune -f
done

# initial consul server
consul_server="consul-server1"
docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})

docker run -d \
  --net=host \
  --hostname ${consul_server} \
  --name ${consul_server} \
  --env "SERVICE_IGNORE=true" \
  --env "CONSUL_CLIENT_INTERFACE=eth0" \
  --env "CONSUL_BIND_INTERFACE=eth1" \
  --volume consul_data:/consul/data \
  --publish 8500:8500 \
  consul:latest \
  consul agent -server -ui -bootstrap-expect=3 -client=0.0.0.0 -advertise=${SWARM_MANAGER_IP} -data-dir="/consul/data"

# next consul servers
consul_servers=( "consul-server2" "consul-server3" )
i=0
for vm in "${vms[@]:1:2}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})

  docker run -d \
    --net=host \
    --hostname ${consul_servers[i]} \
    --name ${consul_servers[i]} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth1" \
    --volume consul_data:/consul/data \
    --publish 8500:8500 \
    consul:latest \
    consul agent -server -ui -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth1" }}' -retry-join=${SWARM_MANAGER_IP} -data-dir="/consul/data"
  let "i++"
done

# consul clients
consul_clients=( "consul-client1" "consul-client2" "consul-client3" )
i=0
for vm in ${vms[@]:3:3}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f $(docker ps -a -q)

  docker run -d \
    --net=host \
    --hostname ${consul_clients[i]} \
    --name ${consul_clients[i]} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth1" \
    --volume consul_data:/consul/data \
    consul:latest \
    consul agent -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth1" }}' -retry-join=${SWARM_MANAGER_IP} -data-dir="/consul/data"
  let "i++"
done

# ##############################################################################

# just informations - checking consul state
docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})
docker logs consul-server1
docker exec -it consul-server1 consul info
docker exec -it consul-server1 consul members

docker-machine env worker1
eval $(docker-machine env worker1)
docker logs consul-agent1

# ##############################################################################

# install registrator
for vm in ${vms[@]:1}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f registrator

  HOST_IP=$(docker-machine ip ${vm})
  echo ${HOST_IP}

  docker run -d \
    --name=registrator \
    --net=host \
    --volume=/var/run/docker.sock:/tmp/docker.sock \
    gliderlabs/registrator:latest \
      -internal consul://${HOST_IP}:8500
done

# ##############################################################################

docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})

# Create overlay network
docker network create \
  --driver overlay \
  --subnet=10.0.0.0/16 \
  --ip-range=10.0.9.0/24 \
  --opt encrypted \
  --attachable=true \
  voter_overlay_net

# Create data volume
for vm in "${vms[@]}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  # docker volume prune -f
  docker volume create --name=voter_data_vol
done

# ##############################################################################

docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})

# Create overlay network
docker network create \
  --driver overlay \
  --subnet=10.0.0.0/16 \
  --ip-range=10.0.11.0/24 \
  --opt encrypted \
  --attachable=true \
  widget_overlay_net

# Create data volume
for vm in "${vms[@]}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  # docker volume prune -f
  docker volume create --name=widget_data_vol
done

# ##############################################################################

# random k/v pairs
docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})
export CONSUL_SERVER=$(docker-machine ip $(docker node ls | grep Leader | awk '{print $3}'))

for i in {1..10} ; do
  KEY=$(openssl rand -hex 8)
  VALUE=$(openssl rand -hex 256)
  echo ${KEY}
  echo ${VALUE}

  curl -X PUT -d @- ${CONSUL_SERVER}:8500/v1/kv/tmp/value/${KEY} <<< ${VALUE}
done

# spring profiles as yaml k/v pairs
docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})
export CONSUL_SERVER=$(docker-machine ip $(docker node ls | grep Leader | awk '{print $3}'))

KEY="config/widget-service/data"
VALUE="consul-configs/default.yaml"
curl -X PUT --data-binary @${VALUE} \
  -H "Content-type: text/x-yaml" \
  ${CONSUL_SERVER}:8500/v1/kv/${KEY}

KEY="config/widget-service/docker-local/data"
VALUE="consul-configs/docker-local.yaml"
curl -X PUT --data-binary @${VALUE} \
  -H "Content-type: text/x-yaml" \
  ${CONSUL_SERVER}:8500/v1/kv/${KEY}

KEY="config/widget-service/docker-production/data"
VALUE="consul-configs/docker-production.yaml"
curl -X PUT --data-binary @${VALUE} \
  -H "Content-type: text/x-yaml" \
  ${CONSUL_SERVER}:8500/v1/kv/${KEY}

# ##############################################################################

docker service create \
  --name=viz \
  --publish=5001:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  manomarks/visualizer:latest
