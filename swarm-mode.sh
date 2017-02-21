#!/bin/sh

set -ex

# ##############################################################################
# Setup Docker Machine hosts for Docker swarm cluster
hosts=( "manager1" "worker1" "worker2"
        "worker3" "worker4" "worker5" )
for vm in "${vms[@]}"
do
  docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "1024" \
    --virtualbox-cpu-count "1" \
    --virtualbox-ui-type "headless" \
    --engine-label role=app
    ${vm}
done

docker-machine ls | grep Running
# manager1       *        virtualbox   Running   tcp://192.168.99.104:2376           v1.13.1
# worker1        -        virtualbox   Running   tcp://192.168.99.101:2376           v1.13.1
# worker2        -        virtualbox   Running   tcp://192.168.99.102:2376           v1.13.1
# worker3        -        virtualbox   Running   tcp://192.168.99.103:2376           v1.13.1
# worker4        -        virtualbox   Running   tcp://192.168.99.106:2376           v1.13.1
# worker5        -        virtualbox   Running   tcp://192.168.99.107:2376           v1.13.1

# ##############################################################################

# http://www.thegeekstuff.com/2010/07/bash-string-manipulation/
# docker swarm leave --force
# rm -rf /var/lib/docker/swarm/*

MANAGER_IP=$(docker-machine ip manager1) && \
  echo ${MANAGER_IP}
docker-machine ssh manager1 "docker swarm init --advertise-addr ${MANAGER_IP}"

WORKER_SWARM_JOIN=$(docker-machine ssh manager1 "docker swarm join-token worker") && \
  WORKER_SWARM_JOIN=$(echo ${WORKER_SWARM_JOIN} | grep -E "(docker).*(2377)" -o) && \
  WORKER_SWARM_JOIN=$(echo ${WORKER_SWARM_JOIN//\\/''}) && \
  echo ${WORKER_SWARM_JOIN}

# docker swarm join \
# --token SWMTKN-1-0fb1vo984vaimgy0z92aggj3esle9c0mkcawxuock77dbad5d9-4ygmbejelg1hndio86cvy4wrh \
# 192.168.99.104:2377

for vm in "${hosts[@]}"
do
  docker-machine ssh ${vm} ${WORKER_SWARM_JOIN}
done

docker-machine env manager1
eval $(docker-machine env manager1)
for vm in ${vms[@]:3:3}
do
  docker node update ${vm} --label-add app=true
done

docker node ls

# ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
# 7qmjwkl4j3bl8auznc8z76bc1    worker5   Ready   Active
# gqzr28qx0q7ugu6bc972alidu    worker4   Ready   Active
# kgbqsmcqdeqybcnjlleqjycmo    worker1   Ready   Active
# qgt3kx67fe5yqyqqwm2fopaw3    worker3   Ready   Active
# r3um9yi9e3uz1ru20cy9qbac6    worker2   Ready   Active
# t9vh7fin89c94cyzvfvdqtrr5 *  manager1  Ready   Active        Leader

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
consul_agent="consul-server1"
docker-machine env ${vms[0]}
eval $(docker-machine env ${vms[0]})
docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --hostname ${consul_agent} \
  --name ${consul_agent} \
  --env "SERVICE_IGNORE=true" \
  --env "CONSUL_CLIENT_INTERFACE=eth0" \
  --env "CONSUL_BIND_INTERFACE=eth1" \
  --volume data:/consul/data \
  --publish 8300:8300 \
  --publish 8301:8301 \
  --publish 8301:8301/udp \
  --publish 8302:8302 \
  --publish 8302:8302/udp \
  --publish 8400:8400 \
  --publish 8500:8500 \
  --publish 172.17.0.1:53:53/udp \
  consul:0.7.5 \
  consul agent -server -ui -bootstrap-expect=3 -client=0.0.0.0 -advertise=${MANAGER_IP} -data-dir="/consul/data"

# next consul servers
consul_agents=( "consul-server2" "consul-server3" )
i=0
for vm in "${vms[@]:1:2}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f $(docker ps -a -q)

  docker run -d \
    --net=host \
    --hostname ${consul_agents[i]} \
    --name ${consul_agents[i]} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth1" \
    --volume data:/consul/data \
    --publish 8300:8300 \
    --publish 8301:8301 \
    --publish 8301:8301/udp \
    --publish 8302:8302 \
    --publish 8302:8302/udp \
    --publish 8400:8400 \
    --publish 8500:8500 \
    --publish 172.17.0.1:53:53/udp \
    consul:0.7.5 \
    consul agent -server -ui -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth1" }}' -retry-join=${MANAGER_IP} -data-dir="/consul/data"
  let "i++"
done

# consul agents
consul_agents=( "consul-agent1" "consul-agent2" "consul-agent3" )
i=0
for vm in ${vms[@]:3:3}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f $(docker ps -a -q)

  docker run -d \
    --net=host \
    --hostname ${consul_agents[i]} \
    --name ${consul_agents[i]} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth1" \
    --volume data:/consul/data \
    --publish 8300:8300 \
    --publish 8301:8301 \
    --publish 8301:8301/udp \
    --publish 8302:8302 \
    --publish 8302:8302/udp \
    --publish 8400:8400 \
    --publish 8500:8500 \
    --publish 172.17.0.1:53:53/udp \
    consul:0.7.5 \
    consul agent -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth1" }}' -retry-join=${MANAGER_IP} -data-dir="/consul/data"
  let "i++"
done

# ##############################################################################

docker-machine env manager1
eval $(docker-machine env manager1)
docker logs consul-server1
docker exec -it consul-server1 consul info
docker exec -it consul-server1 consul members

# ##############################################################################

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

# This node joined a swarm as a worker.

docker-machine ssh manager1 "docker node ls"

docker-machine env manager1
eval $(docker-machine env manager1)

# Create overlay network
docker network create \
  --driver overlay \
  --subnet=10.0.0.0/16 \
  --ip-range=10.0.9.0/24 \
  --opt encrypted \
  --attachable=true \
  consul_overlay_net

# Create data volume
docker volume create --name=data

# ##############################################################################

HOST_IP=$(docker-machine ip manager1)
for i in {1..10} ; do
  KEY=$(openssl rand -hex 8)
  VALUE=$(openssl rand -hex 256)
  echo ${KEY}
  echo ${VALUE}

  curl -X PUT -d @- ${HOST_IP}:8500/v1/kv/tmp/value/${KEY} <<< ${VALUE}
done
