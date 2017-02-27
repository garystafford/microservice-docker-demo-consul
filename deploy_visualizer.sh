#!/bin/sh

# Deploys a single instance Mano Marks’ Docker Swarm Visualizer to a swarm Manager node

set -e

docker service create \
  --name swarm-visualizer \
  --publish 5001:8080/tcp \
  --constraint node.role==manager \
  --mode global \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  --env "SERVICE_IGNORE=true" \
  manomarks/visualizer:latest

echo "Script completed..."
