# Consul

Containerized versions of [progrium/consul](https://hub.docker.com/r/progrium/consul/) Image, using Docker Compose.

#### Versions
Docker Compose versions:
* Development - (1) node server
* Test - (4) node cluster: (3) servers, (1) agent

#### Commands
Install Consul locally
```bash
brew update
brew install Caskroom/cask/consul-cli
```

Single container version for development
```bash
docker-compose -f docker-compose-dev.yml up -d
```

Four-container version for 'Production like' testing
```bash
docker-compose -f docker-compose-test.yml -p widget up -d node1
export JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.widget_default.IPAddress }}' node1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test.yml -p widget up -d node2 node3 node4
```

General commands for dev and test
```bash
docker rm -f node1 node2 node3 node4
dig @0.0.0.0 -p 8600 node1.node.consul
docker exec -t node1 consul info
docker exec -t node1 consul members
docker logs node1
docker volume rm $(docker volume ls -qf dangling=true)
docker exec -t node2 consul leave
docker start node2 # will rejoin

```

#### Running Containers
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                        NAMES
9d30753bb100        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node3
7a73fba8fb8a        progrium/consul     "/bin/start -join 172"   8 minutes ago       Up 8 minutes        53/tcp, 0.0.0.0:8400->8400/tcp, 8300-8302/tcp, 8301-8302/udp, 0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->53/udp   node4
fd6a71c9addf        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node2
5c7436d46310        progrium/consul     "/bin/start -server -"   8 minutes ago       Up 8 minutes        53/tcp, 53/udp, 8300-8302/tcp, 8400/tcp, 8500/tcp, 8301-8302/udp                                             node1
```

#### Local Consul Links  
* [Consul Nodes](http://localhost:8500/v1/catalog/nodes): localhost:8500/v1/catalog/nodes
* [Key/Value Pairs](http://localhost:8500/v1/kv/?recurse): localhost:8500/v1/kv/?recurse
* [Consul UI](http://localhost:8500/ui): localhost:8500/ui
