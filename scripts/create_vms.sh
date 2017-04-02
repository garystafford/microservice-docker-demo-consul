#!/bin/sh

# Creates (6) VirtualBox VMs

set -e

vms=( "manager1" "manager2" "manager3"
      "worker1" "worker2" "worker3" )

# minimally sized for managers
for vm in ${vms[@]:0:3}
do
  docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "512" \
    --virtualbox-cpu-count "1" \
    --virtualbox-disk-size "5000" \
    --engine-label purpose=backend \
    ${vm}
done

# medium sized for apps
for vm in ${vms[@]:3:2}
do
  docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "1024" \
    --virtualbox-cpu-count "1" \
    --virtualbox-disk-size "20000" \
    --engine-label purpose=services \
    ${vm}
done

# larger for elk
for vm in ${vms[@]:5:1}
do
  docker-machine create \
    --driver virtualbox \
    --virtualbox-memory "2048" \
    --virtualbox-cpu-count "2" \
    --virtualbox-disk-size "20000" \
    --engine-label purpose=logging \
    ${vm}
done

docker-machine ls

echo "Script completed..."
