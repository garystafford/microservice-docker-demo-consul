docker stack rm voter_stack
docker stack deploy --compose-file=docker-compose-voter.yml voter_stack
docker stack voter_stack ls
docker stack ps voter_stack


docker stack deploy --compose-file=docker-compose-swarm-mode.yml consul_stack
docker stack ps consul_stack

docker exec -it consul-server1 consul members
docker exec -it consul-server1 consul members --detailed
docker exec -it consul-server1 consul info
docker logs consul-server1

docker exec -it consul-server1 consul force-leave <node>


Consul Commands:
$ docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' consul agent -server -bind=<external ip> -retry-join=<root agent ip> -bootstrap-expect=1

$  docker run -d --net=host -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' consul agent -bind=<external ip> -retry-join=<root agent ip>


https://blog.bugsnag.com/container-orchestration-with-docker-swarm-mode/
https://docs.docker.com/engine/reference/commandline/service_create/#specify-service-constraints-constraint

Node Lookups
============
dig @192.168.99.104 -p 8600
dig @192.168.99.104 -p 8600 *
dig @192.168.99.104 -p 8600 consul-agent1.node.dc1.consul
dig @192.168.99.104 -p 8600 consul-agent1.node.consul ANY
dig @192.168.99.104 -p 8600 consul-agent1.node.consul

Service Lookups
===============
dig +short @192.168.99.104 -p 8600 consul.service.consul SRV
dig @192.168.99.104 -p 8600 consul.service.consul
dig @192.168.99.104 -p 8600 mongodb.service.consul
dig +short @192.168.99.104 -p 8600 candidate-service.service.consul
dig +short @192.168.99.104 -p 8600 candidate-service.service.consul SRV
dig +short @192.168.99.104 -p 8600 widget.service.consul ANY

curl -s http://192.168.99.104:8500/v1/catalog/service/consul | jq .
curl -s http://192.168.99.104:8500/v1/catalog/service/consul?pretty
http 192.168.99.104:8500/v1/catalog/service/candidate-service

curl -s ${HOST_IP}:8500/v1/kv/tmp/value/826c7ab14ca7abe3?raw


docker node ls
docker-machine ssh manager1 "docker stack ps voter_stack"

for i in {1..100} ; do
  KEY=$(openssl rand -hex 4)
  VALUE=$(openssl rand -hex 64)
  echo ${KEY}
  echo ${VALUE}

  curl -X PUT -d @- 192.168.99.104:8500/v1/kv/tmp/value/${KEY} <<< ${VALUE}
done



# Deploy (4) node Consul cluster to multi-host Swarm cluster
DOCKER_HOST=$(docker-machine ip manager1):3376
env | grep DOCKER # confirm env vars

# docker stack deploy --compose-file=docker-compose-test-swarm-mode.yml consul_stack
docker stack deploy --compose-file=docker-compose-swarm-mode.yml consul_stack

docker-compose -f docker-compose-test-swarm-mode.yml -p consul up -d server1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.consul_overlay_net.IPAddress }}' server1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server2
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server3
docker-compose -f docker-compose-test-swarm.yml -p demo up -d agent1
docker network inspect consul_overlay_net # confirm (4) members


docker -H ${DOCKER_HOST} info
