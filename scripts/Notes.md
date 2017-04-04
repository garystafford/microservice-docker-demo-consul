```bash
docker-machine env manager1
eval $(docker-machine env manager1)

docker stack rm monitoring_stack
docker stack ps monitoring_stack --no-trunc
```
