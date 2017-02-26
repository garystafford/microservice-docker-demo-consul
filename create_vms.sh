#!/bin/sh

# Creates (6) VirtualBox VMs

set -e

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
