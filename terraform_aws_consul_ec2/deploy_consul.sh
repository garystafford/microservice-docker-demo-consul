# deploy consul-server1

ssh -i ~/.ssh/consul_aws_rsa ubuntu@<manager1_ip>

SWARM_MANAGER_IP='10.0.1.175'

consul_server="consul-server1"
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
  consul agent -server -ui -client=0.0.0.0 -bootstrap -advertise=${SWARM_MANAGER_IP} -data-dir="/consul/data"

docker exec -it consul-server1 consul members
docker logs consul-server1

ssh -i ~/.ssh/consul_aws_rsa ubuntu@<worker1_ip>

SWARM_MANAGER_IP='10.0.1.175'

consul_server="consul-worker1"
docker run -d \
  --net=host \
  --hostname ${consul_server} \
  --name ${consul_server} \
  --env "SERVICE_IGNORE=true" \
  --env "CONSUL_CLIENT_INTERFACE=eth0" \
  --env "CONSUL_BIND_INTERFACE=eth0" \
  --volume consul_data:/consul/data \
  consul:latest \
  consul agent -client=0.0.0.0 -advertise='{{ GetInterfaceIP "eth0" }}' -retry-join=${SWARM_MANAGER_IP} -data-dir="/consul/data"

docker exec -it consul-worker1 consul members

# ubuntu@ip-10-0-2-102:~$ docker exec -it consul-worker1 consul members
# Node            Address          Status  Type    Build  Protocol  DC
# consul-server1  10.0.1.175:8301  alive   server  0.7.5  2         dc1
# consul-worker1  10.0.2.102:8301  alive   client  0.7.5  2         dc1
