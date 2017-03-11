#!/bin/sh

# Test Consul cluster by creating/reading/deleting k/v pair

set -e

# deploy consul-server-1
echo "Testing Consul cluster..."

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-1 public ip: ${ec2_public_ip}"

key=$(openssl rand -hex 4)
value=$(openssl rand -hex 16)
echo "  key: ${key}"
echo "value: ${value}"

echo "Creating key/value pair..."
curl -s -X PUT -d @- ${ec2_public_ip}:8500/v1/kv/tmp/value/${key} <<< ${value}  > /dev/null

echo "Reading key/value pair..."
curl -s "${ec2_public_ip}:8500/v1/kv/tmp/value/${key}?raw" | \
  grep ${value} && echo "Passed!" || echo "Failed!"

echo "Deleting key/value pair..."
curl -s -X DELETE ${ec2_public_ip}:8500/v1/kv/tmp/value/${key}  > /dev/null

echo "Test complete."
