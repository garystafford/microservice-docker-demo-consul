# Used by all Consul clients
export EC2_SERVER1_PRIVATE_IP=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
echo ${EC2_SERVER1_PRIVATE_IP}

############################################################

# deploy consul-server-1
EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-1' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${EC2_PUBLIC_IP}

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP} \
  "echo export EC2_SERVER1_PRIVATE_IP=${EC2_SERVER1_PRIVATE_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP}

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
    -bootstrap-expect=3 -advertise=${EC2_SERVER1_PRIVATE_IP} \
    -data-dir="/consul/data"

docker exec -it consul-server-1 consul members
docker logs consul-server-1

############################################################

# deploy consul-server-2
EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-2' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${EC2_PUBLIC_IP}

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP} \
  "echo export EC2_SERVER1_PRIVATE_IP=${EC2_SERVER1_PRIVATE_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP}

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
    -retry-join=${EC2_SERVER1_PRIVATE_IP} \
    -data-dir="/consul/data"

docker exec -it consul-server-2 consul members
docker logs consul-server-2

############################################################

# deploy consul-server-3
EC2_PUBLIC_IP=$(aws ec2 describe-instances \
  --filters Name='tag:Name,Values=tf-instance-consul-server-3' \
  --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ${EC2_PUBLIC_IP}

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP} \
"echo export EC2_SERVER1_PRIVATE_IP=${EC2_SERVER1_PRIVATE_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${EC2_PUBLIC_IP}

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
  consul agent -server -ui \
    -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth0" }}' \
    -retry-join=${EC2_SERVER1_PRIVATE_IP} \
    -data-dir="/consul/data"

docker exec -it consul-server-3 consul members
docker logs consul-server-3
