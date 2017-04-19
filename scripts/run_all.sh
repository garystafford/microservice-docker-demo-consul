#!/bin/sh

# Runs all scripts...

set -e

sh ./vms_create.sh
sh ./swarm_create.sh
sh ./ntwk_vols_create.sh
sh ./consul_deploy.sh
sh ./registrator_deploy.sh
sh ./stack_deploy.sh
