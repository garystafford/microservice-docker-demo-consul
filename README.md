# Containerize Consul with Docker Compose

Containerized versions of [progrium/consul](https://hub.docker.com/r/progrium/consul/) Image, using Docker Compose.

### Set-Up Options
Docker Compose versions:  
1. [Development](microservice-docker-demo-consul#single-node): Single Node ([_docker-compose file_ ](docker-compose-dev.yml))  
2. [Test](microservice-docker-demo-consul#cluster): Four-Node Cluster ([_docker-compose file_ ](docker-compose-test.yml))  
3. [Prod-like](microservice-docker-demo-consul#cluster-on-swarm): Multi-Host Cluster ([_docker-compose file_ ](docker-compose-test-swarm.yml))  

### Commands
Software versions used for this project, all latest as of 2016-07-09
```bash
system_profiler SPSoftwareDataType | grep "System Version" | awk '{$1=$1};1' && \
  docker --version && \
  docker-compose --version && \
  docker-machine --version && \
  echo "VirtualBox $(vboxmanage --version)"

  System Version: OS X 10.11.5 (15F34)
  Docker version 1.12.0-rc3, build 91e29e8, experimental
  docker-compose version 1.8.0-rc2, build c72c966
  docker-machine version 0.8.0-rc2, build 4ca1b85
  VirtualBox 5.0.24r108355
```

#### Single Node
Single Consul server node
```bash
docker-compose -f docker-compose-dev.yml up -d
```

#### Cluster
Four-node Consul cluster with (3) servers and (1) agent
```bash
docker-compose -f docker-compose-test.yml -p demo up -d node1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_default.IPAddress }}' node1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test.yml -p demo up -d node2 node3 node4
```

Results
```text
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                        NAMES
9d30753bb100        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node3
7a73fba8fb8a        progrium/consul     "/bin/start -join 172"   8 minutes ago       Up 8 minutes        53/tcp, 0.0.0.0:8400->8400/tcp, 8300-8302/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->53/udp   node4
fd6a71c9addf        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node2
5c7436d46310        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node1
```

Local Consul Links  
* [Consul Nodes](http://localhost:8500/v1/catalog/nodes): localhost:8500/v1/catalog/nodes
* [Key/Value Pairs](http://localhost:8500/v1/kv/?recurse): localhost:8500/v1/kv/?recurse
* [Consul UI](http://localhost:8500/ui): localhost:8500/ui

#### Cluster on Swarm
Four-node Consul cluster, (3) servers and (1) agent, on a multi-host Docker Swarm cluster. Uses overlay networking and persistent storage. One node per host (_i.e. node1 on agent1_)

Setup multi-host Swarm keystore
```bash
docker-machine create -d virtualbox mh-keystore

eval "$(docker-machine env mh-keystore)"

docker run -d \
  -p "8500:8500" \
  -h "consul" \
  progrium/consul -server -bootstrap
```

Setup (4) Docker Machine hosts for Docker Swarm cluster
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

Resulting Machines (VMs)
```text
docker-machine ls
  NAME          ACTIVE   DRIVER       STATE     URL                         SWARM             DOCKER        ERRORS
  agent1        -        virtualbox   Running   tcp://192.168.99.108:2376   agent1 (master)   v1.12.0-rc3
  agent2        -        virtualbox   Running   tcp://192.168.99.109:2376   agent1            v1.12.0-rc3
  agent3        -        virtualbox   Running   tcp://192.168.99.110:2376   agent1            v1.12.0-rc3
  agent4        -        virtualbox   Running   tcp://192.168.99.111:2376   agent1            v1.12.0-rc3
  mh-keystore   *        virtualbox   Running   tcp://192.168.99.105:2376                     v1.12.0-rc3
```

Resulting Docker Swarm containers
``` text
docker ps
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
docker network create --driver overlay --subnet=10.0.9.0/24 demo_overlay_net
eval $(docker-machine env agent1)
```

Deploy (4) node Consul cluster to multi-host Swarm cluster
```bash
DOCKER_HOST=$(docker-machine ip agent1):3376
docker-compose -f docker-compose-test-swarm.yml -p demo up -d node1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_overlay_net.IPAddress }}' node1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p demo up -d node2 node3 node4
docker network inspect demo_overlay_net # confirm (4) members
```

Resulting Network
```text
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
ec7a2e25ea1c        demo_overlay_net    overlay             global
```
Resulting volumes
```text
docker volume ls
  DRIVER              VOLUME NAME
  local               agent1/demo_data
  local               agent2/demo_data
  local               agent3/demo_data
  local               agent4/demo_data
```

Resulting Consul containers
```text
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                                             NAMES
8a0af74866ce        progrium/consul     "/bin/start -server -"   25 minutes ago      Up 25 minutes       53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent3/node3
efe920bbc230        progrium/consul     "/bin/start -server -"   25 minutes ago      Up 25 minutes       53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent2/node2
6541b9db4b54        progrium/consul     "/bin/start -join 10."   25 minutes ago      Up 25 minutes       53/tcp, 192.168.99.111:8400->8400/tcp, 8300-8302/tcp, 8301-8302/udp, 192.168.99.111:8500->8500/tcp, 192.168.99.111:8600->53/udp   agent4/node4
21143f1a643a        progrium/consul     "/bin/start -server -"   25 minutes ago      Up 25 minutes       53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                                                  agent1/node1
```

URLs on my local machine to Consul UI's
* Multi-host Swarm keystore: http://192.168.99.105:8500/ui/#/dc1/nodes/consul
* Containerized Consul cluster: http://192.168.99.111:8500/ui/#/dc1/services/consul


### General Commands
Clean up all project containers and volumes
```bash
docker rm -f node1 node2 node3 node4 # delete all Consul nodes
docker rm -f agent1/node1 agent2/node2 agent3/node3 agent4/node4 # for Swarm version
docker volume rm $(docker volume ls -qf dangling=true) # remove unused local volumes
docker network rm demo_overlay_net
```

General commands for dev and test
```bash
dig @0.0.0.0 -p 8600 node1.node.consul
docker exec -t node1 consul info
docker exec -t node1 consul members
docker logs node1
docker network inspect demo_overlay_net
docker volume rm $(docker volume ls -qf dangling=true) # remove unused local volumes
docker exec -t node2 consul leave # leave cluster
docker start node2 # will rejoin
```
Install Consul locally
```bash
brew update
brew install Caskroom/cask/consul-cli
```
### References
* https://hub.docker.com/r/progrium/consul/
* https://docs.docker.com/engine/userguide/networking/get-started-overlay/
* https://docs.docker.com/compose/compose-file/#/version-2
* https://www.consul.io/docs/
