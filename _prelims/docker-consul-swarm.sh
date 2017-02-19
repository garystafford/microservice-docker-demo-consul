#!/bin/sh

set -ex

# Four-node Consul cluster, (3) servers and (1) agent, on a multi-host Docker Swarm cluster.
# Uses overlay networking and persistent storage. One node per host (_i.e. server1 on master0_)

# Setup multi-host Swarm keystore
docker-machine create -d virtualbox consul0
eval "$(docker-machine env consul0)"
docker run -d -p "8500:8500" -h "consul" \
  --name consul gliderlabs/consul-server \
  -server -bootstrap

# Setup (4) Docker Machine hosts for Docker Swarm cluster
docker-machine create \
  -d virtualbox \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  master0

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node0

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node1

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node2

docker volume create --name=data

# Build Overlay Network
eval $(docker-machine env --swarm master0)
docker network create --driver overlay --subnet=10.0.9.0/24 demo_overlay_net
eval $(docker-machine env master0)

# Deploy (4) node Consul cluster to multi-host Swarm cluster
DOCKER_HOST=$(docker-machine ip master0):3376
env | grep DOCKER # confirm env vars

docker-compose -f docker-compose-test-swarm.yml -p demo up -d server1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_overlay_net.IPAddress }}' server1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server2
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server3
docker-compose -f docker-compose-test-swarm.yml -p demo up -d agent1
docker network inspect demo_overlay_net # confirm (4) members

docker -H ${DOCKER_HOST} info
