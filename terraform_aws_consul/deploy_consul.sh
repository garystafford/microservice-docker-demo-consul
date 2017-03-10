#!/bin/sh

# Deploys a cluster of (3) Consul Servers to (3) EC2 Instances

# set -e


# Used by all Consul clients
export ec2_server1_private_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
echo ${ec2_server1_private_ip}

############################################################

# deploy consul-server-1
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${ec2_public_ip}


# ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP} -c \
#   "echo export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc"

ssh -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << 'EOSSH'
  export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc
  consul_server="consul-server-1"
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
      -bootstrap-expect=3 -advertise=${ec2_server1_private_ip} \
      -data-dir="/consul/data"

  sleep 3
  docker exec -it consul-server-1 consul members
  docker logs consul-server-1
EOSSH

############################################################

# deploy consul-server-2
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-2' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${ec2_public_ip}

ssh -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << 'EOSSH'
  export ec2_server1_private_ip=${ec2_server1_private_ip} >> ~/.bashrc
  consul_server="consul-server-2"

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
  docker exec -it consul-server-2 consul members
  docker logs consul-server-2
EOSSH

############################################################

# deploy consul-server-3
ec2_public_ip=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-3' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${ec2_public_ip}

ssh -T -i ~/.ssh/consul_aws_rsa ubuntu@${ec2_public_ip} << EOSSH
  ec2_server1_private_ip=${ec2_server1_private_ip}
  consul_server="consul-server-3"

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
  docker exec -it consul-server-2 consul members
  docker logs consul-server-2
EOSSH
