#!/bin/sh

# Test Consul Server Cluster

# set -e

# deploy consul-server-1
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${ec2_public_ip}

key=$(openssl rand -hex 4)
value=$(openssl rand -hex 64)
echo ${key}
echo ${value}

curl -X PUT -d @- ${ec2_public_ip}:8500/v1/kv/tmp/value/${key} <<< ${value}

curl -s ${ec2_public_ip}:8500/v1/kv/tmp/value/${value}?raw
