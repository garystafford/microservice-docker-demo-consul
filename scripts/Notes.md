# Fluentd / ELK Stack

Helpful commands

```bash
docker-machine env manager1
eval $(docker-machine env manager1)

docker stack rm monitoring_stack
docker stack ps monitoring_stack --no-trunc

docker service rm monitoring_stack_fluentd

docker-machine env worker2
eval $(docker-machine env worker2)

docker exec -it  $(docker ps | grep fluent | awk '{print $NF}') cat /fluentd/log/docker.log && date -u
docker logs  $(docker ps | grep fluent | awk '{print $NF}') --follow
docker container inspect  $(docker ps | grep fluent | awk '{print $NF}')

HOST_IP=$(docker-machine ip manager1)
echo ${HOST_IP}
dig +short @${HOST_IP} widget.service.consul ANY

```

## References

- <http://www.fluentd.org/guides/recipes/docker-logging>
- <https://github.com/fluent/fluentd-docker-image>

## Fix VM Max Error on VM for ELK Container

```bash
docker-machine ssh worker3 sudo sysctl -w vm.max_map_count=262144
docker-machine ssh worker3 sudo sysctl -n vm.max_map_count
```
