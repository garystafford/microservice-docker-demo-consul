# Consul

Containerized versions of [progrium/consul](https://hub.docker.com/r/progrium/consul/) Image, using Docker Compose.


#### Commands
Create local volume
```bash
docker volume create --name=data
```

Single container version for development
```bash
docker-compose -f docker-compose-dev.yml up -d
```

Four-container version for 'Production like' testing
```bash
docker rm -f node1 node2 node3 node4

docker-compose -f docker-compose-test.yml -p widget up -d node1
JOIN_IP="$(docker inspect --format '{{ .NetworkSettings.Networks.widget_default.IPAddress }}' node1)"
echo ${JOIN_IP}
docker-compose -f docker-compose-test.yml -p widget up -d node2 node3 node4
```

General commands for dev and test
```bash
docker exec -t node1 consul members
docker logs node1
dig @0.0.0.0 -p 8600 node1.node.consul
docker volume rm $(docker volume ls -qf dangling=true)
```

#### Links  
* [Consul Nodes](curl http://localhost:8500/v1/catalog/nodes): localhost:8500/v1/catalog/nodes
* [Key/Value Pairs](http://localhost:8500/v1/kv/?recurse): localhost:8500/v1/catalog/nodes
* [Consul UI](http://localhost:8500/ui): localhost:8500/ui
