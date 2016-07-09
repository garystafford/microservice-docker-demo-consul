# Install Consul on Docker Swarm Cluster
Build a multi-host Docker Swarm cluster, using Overlay networking. Deploy a multi-node Consul cluster to the Swarm multi-host cluster.

#### Commands
Setup multi-host Swarm keystore
```bash
docker-machine create \
  -d virtualbox \
  mh-keystore

eval "$(docker-machine env mh-keystore)"

docker run -d \
  -p "8500:8500" \
  -h "consul" \
  progrium/consul -server -bootstrap
```

Setup (4) host Swarm cluster
```bash
docker-machine create \
  -d virtualbox \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  agent1

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  agent2

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  agent3

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  agent4
```

Results from setup
```text
docker-machine ls | grep Running
  agent1        -        virtualbox   Running   tcp://192.168.99.108:2376   agent1 (master)   v1.12.0-rc3
  agent2        -        virtualbox   Running   tcp://192.168.99.109:2376   agent1            v1.12.0-rc3
  agent3        -        virtualbox   Running   tcp://192.168.99.110:2376   agent1            v1.12.0-rc3
  agent4        -        virtualbox   Running   tcp://192.168.99.111:2376   agent1            v1.12.0-rc3
  mh-keystore   -        virtualbox   Running   tcp://192.168.99.105:2376                     v1.12.0-rc3

docker ps -a
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                     NAMES
  36d862e2a4bf        swarm:latest        "/swarm join --advert"   22 minutes ago      Up 22 minutes       2375/tcp                                  agent4/swarm-agent
  57ac46a80769        swarm:latest        "/swarm join --advert"   24 minutes ago      Up 24 minutes       2375/tcp                                  agent3/swarm-agent
  c29c2143dbe0        swarm:latest        "/swarm join --advert"   25 minutes ago      Up 25 minutes       2375/tcp                                  agent2/swarm-agent
  032359303fab        swarm:latest        "/swarm join --advert"   26 minutes ago      Up 26 minutes       2375/tcp                                  agent1/swarm-agent
  bb34ce9a30c8        swarm:latest        "/swarm manage --tlsv"   26 minutes ago      Up 26 minutes       2375/tcp, 192.168.99.108:3376->3376/tcp   agent1/swarm-agent-master
```

Build Overlay Network
```bash
eval $(docker-machine env --swarm agent1)
docker network create --driver overlay --subnet=10.0.9.0/24 widget_overlay_net
eval $(docker-machine env agent1)
docker network ls
  ee39ebc3bd60        widget_overlay_net   overlay             global

docker network inspect widget_overlay_net
```

Deploy (4) node Consul cluster to (4) host Swarm cluster
```bash
DOCKER_HOST=$(docker-machine ip agent1):3376
docker-compose -f docker-compose-test-swarm.yml -p widget up -d node1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.widget_overlay_net.IPAddress }}' node1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p widget up -d node2 node3 node4
```
Output
```text
docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                                             NAMES
  7fb69c8c8fb0        progrium/consul     "/bin/start -join 10."   2 minutes ago       Up 2 minutes        53/tcp, 192.168.99.111:8400->8400/tcp, 8300-8302/tcp, 8301-8302/udp, 192.168.99.111:8500->8500/tcp, 192.168.99.111:8600->53/udp   agent4/node4
  c645a612eea0        progrium/consul     "/bin/start -server -"   2 minutes ago       Up 2 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent2/node2
  8b334645b423        progrium/consul     "/bin/start -server -"   2 minutes ago       Up 2 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent3/node3
  1ccfc35adab5        progrium/consul     "/bin/start -server -"   3 minutes ago       Up 3 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent1/node1
```

#### References
Paths on my local machine to UI's
* Multi-host Swarm keystore: http://192.168.99.105:8500/ui/#/dc1/nodes/consul
* Consul cluster: http://192.168.99.111:8500/ui/#/dc1/services/consul

Source References: https://docs.docker.com/engine/userguide/networking/get-started-overlay/
