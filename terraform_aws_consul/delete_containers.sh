#!/bin/sh

# Deploys a cluster of (3) Consul Servers to (3) EC2 Instances

# set -e

# consul-server-3
echo " "
echo "*** Deleting consul-server-3 container... ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-3' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
  echo "consul-server-3 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "docker rm -f -v consul-server-3 && echo 'Container deleted...' || echo 'No container exists?'"

############################################################

# consul-server-2
echo " "
echo "*** Deleting consul-server-2 container... ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-2' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
  echo "consul-server-2 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "docker rm -f -v consul-server-2 && echo 'Container deleted...' || echo 'No container exists?'"

############################################################

# consul-server-1
echo " "
echo "*** Deleting consul-server-1 container... ***"

ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "consul-server-1 public ip: ${ec2_public_ip}"

ssh -oStrictHostKeyChecking=no -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} \
  "docker rm -f -v consul-server-1 && echo 'Container deleted...' || echo 'No container exists?'"
