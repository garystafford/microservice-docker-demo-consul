# Used by all Consul clients
export CONSUL_SERVER_IP=$(aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-1' --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')

############################################################
# deploy consul-server-1
export CONSUL_SERVER_PUBLIC_1_IP=$(aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-1' --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_PUBLIC_1_IP} "echo export CONSUL_SERVER_IP=${CONSUL_SERVER_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_PUBLIC_1_IP}

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
  consul agent -server -ui -client=0.0.0.0 -bootstrap-expect=3 -advertise=${CONSUL_SERVER_IP} -data-dir="/consul/data"

docker exec -it consul-server-1 consul members
docker logs consul-server-1

############################################################
# deploy consul-server-2
export CONSUL_SERVER_2_PUBLIC_IP=$(aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-2' --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_2_PUBLIC_IP} "echo export CONSUL_SERVER_IP=${CONSUL_SERVER_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_2_PUBLIC_IP}

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
  consul agent -server -ui -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth0" }}' -retry-join=${CONSUL_SERVER_IP} -data-dir="/consul/data"

docker exec -it consul-server-2 consul members
docker logs consul-server-2

############################################################
# deploy consul-server-3
export CONSUL_SERVER_3_PUBLIC_IP=$(aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-server-3' --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_3_PUBLIC_IP} "echo export CONSUL_SERVER_IP=${CONSUL_SERVER_IP} >> ~/.bashrc"

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_3_PUBLIC_IP}

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
  consul agent -server -ui -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth0" }}' -retry-join=${CONSUL_SERVER_IP} -data-dir="/consul/data"

docker exec -it consul-server-3 consul members
docker logs consul-server-3

############################################################

export CONSUL_SERVER_PUBLIC_IP=$(aws ec2 describe-instances --filters Name='tag:Name,Values=tf-instance-consul-client-3' --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

ssh -i ~/.ssh/consul_aws_rsa ubuntu@${CONSUL_SERVER_PUBLIC_IP}

export CONSUL_SERVER_IP=10.0.1.219

consul_server="consul-client-1"
docker run -d \
  --net=host \
  --hostname ${consul_server} \
  --name ${consul_server} \
  --env "SERVICE_IGNORE=true" \
  --env "CONSUL_CLIENT_INTERFACE=eth0" \
  --env "CONSUL_BIND_INTERFACE=eth0" \
  --volume consul_data:/consul/data \
  consul:latest \
  consul agent -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth0" }}' -retry-join=${CONSUL_SERVER_IP} -data-dir="/consul/data"

docker exec -it consul-client1 consul members

# ubuntu@ip-10-0-2-102:~$ docker exec -it consul-client1 consul members
# Node            Address          Status  Type    Build  Protocol  DC
# consul-server1  10.0.1.175:8301  alive   server  0.7.5  2         dc1
# consul-client1  10.0.2.102:8301  alive   client  0.7.5  2         dc1
