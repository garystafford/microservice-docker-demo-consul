#!/bin/sh

# Remove all containers, networks, and volumes from all hosts
# --all removes all unused images, not just dangling ones!

set -e

vms=( "manager1" "manager2" "manager3"
      "worker1" "worker2" "worker3" )

for vm in ${vms[@]}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker ps -a
  docker images
  docker system prune -f #--all
done
