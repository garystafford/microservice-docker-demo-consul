#!/bin/sh

# Deploys a cluster of (3) Consul Servers to (3) EC2 Instances

set -e

# value used by all consul clients
export ec2_server1_private_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
echo "consul-server-1 private ip: ${ec2_server1_private_ip}"

############################################################

# deploy consul-server-1
echo ""
echo "*** Deploying consul-server-1 ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-1 public ip: ${ec2_public_ip}"

consul_server="consul-server-1"

ssh -oStrictHostKeyChecking=no -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << EOSSH
  echo "consul-server-1 private ip: ${ec2_server1_private_ip}"
  echo "consul_server: ${consul_server}"

  docker run -d \
    --net=host \
    --hostname ${consul_server} \
    --name ${consul_server} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth0" \
    --volume consul_data:/consul/data \
    --publish 8500:8500 \
    consul:latest \
    consul agent -server -ui -client=0.0.0.0 \
      -bootstrap-expect=3 \
      -advertise='{{ GetInterfaceIP "eth0" }}' \
      -data-dir="/consul/data"

  sleep 3
  docker logs consul-server-1
  docker exec -i consul-server-1 consul members
EOSSH

sleep 5
############################################################

# deploy consul-server-2
echo ""
echo "*** Deploying consul-server-2 ***"

echo "consul-server-1 private ip: ${ec2_server1_private_ip}"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-2' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-2 public ip: ${ec2_public_ip}"

consul_server="consul-server-2"

ssh -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << EOSSH
  echo "consul-server-1 private ip: ${ec2_server1_private_ip}"
  echo "consul_server: ${consul_server}"

  docker run -d \
    --net=host \
    --hostname ${consul_server} \
    --name ${consul_server} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth0" \
    --volume consul_data:/consul/data \
    --publish 8500:8500 \
    consul:latest \
    consul agent -server -ui -client=0.0.0.0 \
      -advertise='{{ GetInterfaceIP "eth0" }}' \
      -retry-join="${ec2_server1_private_ip}" \
      -data-dir="/consul/data"

  sleep 5
  docker logs consul-server-2
  docker exec -i consul-server-2 consul members
EOSSH

############################################################

# deploy consul-server-3
echo ""
echo "*** Deploying consul-server-3 ***"

echo "consul-server-1 private ip: ${ec2_server1_private_ip}"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-3' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-3 public ip: ${ec2_public_ip}"

consul_server="consul-server-3"

ssh -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << EOSSH
  docker run -d \
    --net=host \
    --hostname ${consul_server} \
    --name ${consul_server} \
    --env "SERVICE_IGNORE=true" \
    --env "CONSUL_CLIENT_INTERFACE=eth0" \
    --env "CONSUL_BIND_INTERFACE=eth0" \
    --volume consul_data:/consul/data \
    --publish 8500:8500 \
    consul:latest \
    consul agent -server -ui -client=0.0.0.0 \
      -advertise='{{ GetInterfaceIP "eth0" }}' \
      -retry-join="${ec2_server1_private_ip}" \
      -data-dir="/consul/data"

  sleep 5
  docker logs consul-server-3
  docker exec -i consul-server-3 consul members
EOSSH

############################################################

# output consul ui url
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ""
echo "*** Consul UI: http://${ec2_public_ip}:8500/ui/ ***"
