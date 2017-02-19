#!/bin/sh

set -ex

# ##############################################################################
# Setup (4) Docker Machine hosts for Docker Swarm cluster
vms=( "manager1" "worker1" "worker2" "worker3" "worker4" "worker5" )
for vm in "${vms[@]}"
do
  docker-machine create -d virtualbox ${vm}
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

for vm in "${vms[@]}"
do
  docker-machine ssh ${vm} ${WORKER_SWARM_JOIN}
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

docker-machine env manager1
eval $(docker-machine env manager1)

docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --hostname "consul-server1" \
  --env SERVICE_IGNORE=true \
  --name consul-server1 \
  --volume data:/consul/data \
  consul \
  consul agent -server -ui -bootstrap-expect=3 -client=0.0.0.0 -bind=192.168.99.104 -data-dir=/consul/data

docker logs consul-server1
docker exec -it consul-server1 consul members
docker exec -it consul-server1 consul info

docker-machine env worker1
eval $(docker-machine env worker1)

docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --hostname "consul-server2" \
  --env SERVICE_IGNORE=true \
  --name consul-server2 \
  --volume data:/consul/data \
  consul \
  consul agent -server -client=0.0.0.0 -bind=192.168.99.101 -retry-join=192.168.99.104 -data-dir=/consul/data

docker logs consul-server2

docker-machine env worker2
eval $(docker-machine env worker2)

docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --hostname "consul-server3" \
  --env SERVICE_IGNORE=true \
  --name consul-server3 \
  --volume data:/consul/data \
  consul \
  consul agent -server -client=0.0.0.0 -bind=192.168.99.102 -retry-join=192.168.99.104 -data-dir=/consul/data

docker logs consul-server3

docker-machine env worker3
eval $(docker-machine env worker3)

docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --hostname "consul-agent1" \
  --name consul-agent1 \
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
  --publish 53:53/udp \
  consul \
  consul agent -bind='{{ GetInterfaceIP "eth0" }}' -retry-join=${MANAGER_IP} -data-dir=/tmp/consul

docker logs consul-agent1

docker-machine env worker4
eval $(docker-machine env worker4)

docker rm -f $(docker ps -a -q)

docker run -d \
  --net=host \
  --name consul-agent2 \
  --hostname "consul-agent2" \
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
  --publish 53:53/udp \
  consul \
  consul agent -bind='{{ GetInterfaceIP "eth0" }}' -retry-join=${MANAGER_IP} -data-dir=/tmp/consul

docker logs consul-agent2
docker exec -it consul-agent2 sh
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

# Deploy (4) node Consul cluster to multi-host Swarm cluster
DOCKER_HOST=$(docker-machine ip manager1):3376
env | grep DOCKER # confirm env vars

# docker stack deploy --compose-file=docker-compose-test-swarm-mode.yml consul_stack
docker stack deploy --compose-file=docker-compose-swarm-mode.yml consul_stack

docker-compose -f docker-compose-test-swarm-mode.yml -p consul up -d server1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.consul_overlay_net.IPAddress }}' server1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server2
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server3
docker-compose -f docker-compose-test-swarm.yml -p demo up -d agent1
docker network inspect consul_overlay_net # confirm (4) members

docker -H ${DOCKER_HOST} info
