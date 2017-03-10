#!/bin/sh

# Deploys a cluster of (3) Consul Servers to (3) EC2 Instances

# set -e

# deploy consul-server-1
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${ec2_public_ip}

curl ec2_public_ip:8500
