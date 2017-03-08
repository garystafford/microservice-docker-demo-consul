#!/bin/sh

# Remove all unused images not just dangling ones from all hosts

set -e

# remove all containers, networks, and volumes
vms=( "manager1" "manager2" "manager3"
 "worker1" "worker2" "worker3" )

for vm in ${vms[@]}
do
  docker-machine env ${vm}
  eval $(docker-machine env ${vm})
  docker system prune -f --all
done
