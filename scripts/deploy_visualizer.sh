#!/bin/sh

# Deploys single instance Mano Marks’
# Docker Swarm Visualizer to a swarm Manager node

set -e

docker-machine env manager1
eval $(docker-machine env manager1)

docker service create \
  --name swarm-visualizer \
  --publish 5001:8080/tcp \
  --constraint "node.hostname == manager1" \
  --mode global \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  --env "SERVICE_IGNORE=true" \
  manomarks/visualizer:latest \
|| echo "Already installed?"

echo "Script completed..."
