## Containerize Consul with Docker Compose and Swarm

Containerized versions Consul, using the [progrium/consul](https://hub.docker.com/r/progrium/consul/) Docker Image. Individual Docker run commands from the [progrium/consul](https://hub.docker.com/r/progrium/consul/) instructions have been converted into Version 2 Docker Compose files, using latest Docker toolkit versions. Includes instructions for setting up a multi-host Docker Swarm environment, for a Consul cluster. Currently, uses VirtualBox VMs as hosts.

![Consul UI Swarm](https://github.com/garystafford/consul-docker-swarm-compose/blob/master/previews/Consul_UI_Swarm.png?raw=true)

### Set-Up Options
Docker Compose versions:  
1. [Development](microservice-docker-demo-consul#single-node): Single Node ([_docker-compose file_](docker-compose-dev.yml))  
2. [Test](microservice-docker-demo-consul#cluster): Four-Node Cluster ([_docker-compose file_](docker-compose-test.yml))  
3. [Prod-like](microservice-docker-demo-consul#cluster-on-swarm): Multi-Host Cluster with Swarm ([_docker-compose file_](docker-compose-test-swarm.yml))  

### Commands
#### Single Node
Single Consul server node
```bash
docker-compose -f docker-compose-dev.yml up -d
```

#### Four-Node Cluster
Four-node Consul cluster with (3) servers and (1) agent
```bash
docker-compose -f docker-compose-test.yml -p demo up -d server1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_default.IPAddress }}' server1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test.yml -p demo up -d server2 server3 agent1
```

Results
```text
docker ps
  CONTAINER ID        IMAGE                      COMMAND                  CREATED              STATUS              PORTS                                                                                                                    NAMES
  745cb8b0cf6e        gliderlabs/consul-server   "/bin/consul agent -s"   16 seconds ago       Up 15 seconds       8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                     server2
  7ce07e7e92df        gliderlabs/consul-agent    "/bin/consul agent -c"   16 seconds ago       Up 15 seconds       0.0.0.0:8400->8400/tcp, 8300-8302/tcp, 8301-8302/udp, 8600/tcp, 8600/udp, 0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->53/udp   agent1
  ac542653fd34        gliderlabs/consul-server   "/bin/consul agent -s"   16 seconds ago       Up 15 seconds       8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                     server3
  db053d540c64        gliderlabs/consul-server   "/bin/consul agent -s"   About a minute ago   Up About a minute   8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp, 8600/tcp, 8600/udp                                                     server1
```
![Consul UI No Swarm](https://github.com/garystafford/consul-docker-swarm-compose/blob/master/previews/Consul_UI_No_Swarm.png?raw=true)

Local Consul Links  
* [Consul Nodes](http://localhost:8500/v1/catalog/nodes): localhost:8500/v1/catalog/nodes
* [Key/Value Pairs](http://localhost:8500/v1/kv/?recurse): localhost:8500/v1/kv/?recurse
* [Consul UI](http://localhost:8500/ui): localhost:8500/ui

#### Multi-Host Cluster with Swarm
Four-node Consul cluster, (3) servers and (1) agent, on a multi-host Docker Swarm cluster. Uses overlay networking and persistent storage. One node per host (_i.e. server1 on master0_)

Setup multi-host Swarm keystore
```bash
docker-machine create -d virtualbox consul0

eval "$(docker-machine env consul0)"

docker run -d -p "8500:8500" -h "consul" --name consul gliderlabs/consul-server -server -bootstrap
```

![Consul UI](https://github.com/garystafford/consul-docker-swarm-compose/blob/master/previews/Consul_UI.png?raw=true)

Setup (4) Docker Machine hosts for Docker Swarm cluster
```bash
docker-machine create \
  -d virtualbox \
  --swarm --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  master0

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node0

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node1

docker-machine create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul0):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  node2
```

Resulting Machines (VMs)
```text
docker-machine ls
NAME          ACTIVE   DRIVER       STATE     URL                         SWARM              DOCKER        ERRORS
consul0       -        virtualbox   Running   tcp://192.168.99.100:2376                      v1.12.0-rc3
master0       -        virtualbox   Running   tcp://192.168.99.101:2376   master0 (master)   v1.12.0-rc3
node0         -        virtualbox   Running   tcp://192.168.99.103:2376   master0            v1.12.0-rc3
node1         -        virtualbox   Running   tcp://192.168.99.104:2376   master0            v1.12.0-rc3
node2         -        virtualbox   Running   tcp://192.168.99.102:2376   master0            v1.12.0-rc3
```

Resulting Docker Swarm containers
```text
docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                     NAMES
e6edfc92a0df        swarm:latest        "/swarm join --advert"   11 minutes ago      Up 11 minutes       2375/tcp                                  node2/swarm-agent
81960dfae82d        swarm:latest        "/swarm join --advert"   12 minutes ago      Up 12 minutes       2375/tcp                                  node1/swarm-agent
bb302d9451ee        swarm:latest        "/swarm join --advert"   13 minutes ago      Up 13 minutes       2375/tcp                                  node0/swarm-agent
69fda652a704        swarm:latest        "/swarm join --advert"   14 minutes ago      Up 14 minutes       2375/tcp                                  master0/swarm-agent
2f8018faccdb        swarm:latest        "/swarm manage --tlsv"   14 minutes ago      Up 14 minutes       2375/tcp, 192.168.99.101:3376->3376/tcp   master0/swarm-agent-master
```

Build Overlay Network
```bash
eval $(docker-machine env --swarm master0)
docker network create --driver overlay --subnet=10.0.9.0/24 demo_overlay_net
eval $(docker-machine env master0)
```

Deploy (4) node Consul cluster to multi-host Swarm cluster
```bash
DOCKER_HOST=$(docker-machine ip master0):3376
env | grep DOCKER # confirm env vars
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.demo_overlay_net.IPAddress }}' server1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test-swarm.yml -p demo up -d server2 server3 agent1
docker network inspect demo_overlay_net # confirm (4) members
```

Resulting Network
```text
docker network ls
NETWORK ID          NAME                      DRIVER              SCOPE
27fab44006ec        demo_overlay_net          overlay             global
```

Resulting volumes
```text
docker volume ls
DRIVER              VOLUME NAME
local               master0/demo_data
local               node0/demo_data
local               node1/demo_data
local               node2/demo_data
```

Resulting Consul containers
```text
docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                                                                                                                                                                                                      NAMES
12d33b43b119        gliderlabs/consul-agent    "/bin/consul agent -c"   About an hour ago   Up 59 minutes       192.168.99.102:53->53/tcp, 192.168.99.102:53->53/udp, 192.168.99.102:8300-8302->8300-8302/tcp, 192.168.99.102:8400->8400/tcp, 192.168.99.102:8500->8500/tcp, 192.168.99.102:8301-8302->8301-8302/udp, 8600/tcp, 8600/udp   node2/agent1
84a0fef6e206        gliderlabs/consul-server   "/bin/consul agent -s"   About an hour ago   Up 59 minutes       192.168.99.103:53->53/tcp, 192.168.99.103:53->53/udp, 192.168.99.103:8300-8302->8300-8302/tcp, 192.168.99.103:8400->8400/tcp, 192.168.99.103:8500->8500/tcp, 192.168.99.103:8301-8302->8301-8302/udp, 8600/tcp, 8600/udp   node0/server2
657df118725f        gliderlabs/consul-server   "/bin/consul agent -s"   About an hour ago   Up 59 minutes       192.168.99.104:53->53/tcp, 192.168.99.104:53->53/udp, 192.168.99.104:8300-8302->8300-8302/tcp, 192.168.99.104:8400->8400/tcp, 192.168.99.104:8500->8500/tcp, 192.168.99.104:8301-8302->8301-8302/udp, 8600/tcp, 8600/udp   node1/server3
584075b1e229        gliderlabs/consul-server   "/bin/consul agent -s"   About an hour ago   Up 59 minutes       192.168.99.101:53->53/tcp, 192.168.99.101:53->53/udp, 192.168.99.101:8300-8302->8300-8302/tcp, 192.168.99.101:8400->8400/tcp, 192.168.99.101:8500->8500/tcp, 192.168.99.101:8301-8302->8301-8302/udp, 8600/tcp, 8600/udp   master0/server1
```

```text
docker exec -t master0/server1 consul members
Node     Address         Status  Type    Build  Protocol  DC
agent1   10.0.9.14:8301  alive   client  0.6.4  2         dc1
server1  10.0.9.11:8301  alive   server  0.6.4  2         dc1
server2  10.0.9.12:8301  alive   server  0.6.4  2         dc1
server3  10.0.9.13:8301  alive   server  0.6.4  2         dc1
```

![Consul UI Swarm](https://github.com/garystafford/consul-docker-swarm-compose/blob/master/previews/Consul_UI_Swarm.png?raw=true)

URLs on my local machine to Consul UI's
* Multi-host Swarm keystore: http://192.168.99.104:8500/ui/#/dc1/nodes/consul
* Containerized Consul cluster: http://192.168.99.100:8500/ui/#/dc1/services/consul

### Calling Key/Value Store
Retrieve existing value from key/value store
```bash
curl -s http://192.168.99.104:8500/v1/kv/development/spring/data/mongodb/port?raw
> 27017
```
![Consul UI Key/Value](https://github.com/garystafford/consul-docker-swarm-compose/blob/master/previews/Consul_UI_KeyValue.png?raw=true)

### Misc Items
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

Clean up all project containers and volumes
```bash
docker rm -f server1 server2 server3 agent1 # delete all Consul nodes
docker rm -f master0/server1 node0/server2 node1/server3 node2/agent1 # for Swarm version
docker volume rm $(docker volume ls -qf dangling=true) # remove unused local volumes
docker network rm demo_overlay_net
```

Clean up all project machines
```bash
docker-machine rm master0 node0 node1 node4 consul0
eval $(docker-machine env --unset)
```

Useful commands
```bash
dig @0.0.0.0 -p 8600 node1.node.consul
docker exec -t master0/server1 consul info
docker exec -t master0/server1 consul members
docker logs master0/server1
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
* https://docs.docker.com/swarm/install-manual/
* https://github.com/gliderlabs/registrator/issues/349
* https://github.com/JoergM/consul-examples/tree/master/http_api
