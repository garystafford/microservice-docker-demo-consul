#!/bin/sh

# Deploys a cluster of (3) Consul Servers to (3) EC2 Instances

# set -e

# Used by all Consul clients
export ec2_server1_private_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
  echo "consul-server-1 private ip: ${ec2_server1_private_ip}"

############################################################

# deploy consul-server-1
echo "*** Deploying consul-server-1 ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-1 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "echo export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc && exec bash"

ssh -T -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << 'EOSSH'
  export consul_server="consul-server-1"
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

############################################################

# deploy consul-server-2
echo "*** Deploying consul-server-2 ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-2' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
  echo "consul-server-2 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "echo export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc && exec bash"

ssh -T -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << 'EOSSH'
  export consul_server="consul-server-2"
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
      -retry-join=${ec2_server1_private_ip} \
      -data-dir="/consul/data"
  sleep 3
  docker logs consul-server-2
  docker exec -i consul-server-2 consul members
EOSSH

############################################################

# deploy consul-server-3
echo "*** Deploying consul-server-3 ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-3' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
  echo "consul-server-3 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "echo export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc && exec bash"

ssh -T -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << 'EOSSH'
  export consul_server="consul-server-3"
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
      -retry-join=${ec2_server1_private_ip} \
      -data-dir="/consul/data"

  sleep 3
  docker logs consul-server-3
  docker exec -i consul-server-3 consul members
EOSSH

############################################################

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "*** Consul UI: ec2_public_ip ***"
