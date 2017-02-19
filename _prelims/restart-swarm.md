## Restart Swarm Cluster and Consul Cluster
_Work in progress! Not fully tested..._

How to restart Swarm cluster with VirtualBox, after system restart. Since it uses DHCP, there is no
 guarantee that the IP addresses of the VMs will be the same. Must regen certs
 and rebuild Swarm containers.

```bash
docker-machine start consul0
docker-machine regenerate-certs consul0
eval "$(docker-machine env consul0)"
docker start consul

========================================================

docker-machine start master0 node0 node1 node2
docker-machine upgrade master0 node0 node1 node2
docker-machine regenerate-certs master0 node0 node1 node2

eval "$(docker-machine env master0)"
docker rm swarm-agent swarm-agent-master
docker-machine provision master0

eval "$(docker-machine env node0)"
docker rm swarm-agent
docker-machine provision node0

eval "$(docker-machine env node1)"
docker rm swarm-agent
docker-machine provision node1

eval "$(docker-machine env node2)"
docker rm swarm-agent
docker-machine provision node2

eval "$(docker-machine env master0)"
DOCKER_HOST=$(docker-machine ip master0):3376
docker start master0/server1

export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_overlay_net.IPAddress }}' server1)"
echo ${JOIN_IP}
docker start node0/server2
docker start node1/server3
docker start node2/agent1

# docker stop master0/server1 node0/server2 node1/server3 node2/agent1
# docker exec -t node0/server2 consul -server -join ${JOIN_IP}
```
