#!/bin/sh

# Delete all containers

set -e

vms=( "manager1" "manager2" "manager3"
      "worker1" "worker2" "worker3" )

SWARM_MANAGER_IP=$(docker-machine ip manager1)
echo ${SWARM_MANAGER_IP}

for vm in ${vms[@]}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})

  docker stop $(docker ps -a -q) || echo "No containers..."
  docker rm $(docker ps -a -q) || echo "No containers..."
done
