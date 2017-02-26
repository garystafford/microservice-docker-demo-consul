#!/bin/sh

# Cleans up swarm cluster by deleting all the containers, networks, and volumes
# Leaves swarm cluster intact

set -e

vms=( "manager1" "manager2" "manager3"
 "worker1" "worker2" "worker3" )

for vm in "${vms[@]}"
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker rm -f $(docker ps -a -q)
  docker network prune -f
  docker volume prune -f
done
