```bash
docker build -t garystafford/consul:latest .
docker tag garystafford/consul:latest garystafford/consul:0.1
docker push garystafford/consul:latest
docker push garystafford/consul:0.1

docker build -t garystafford/consul-agent:latest .
docker tag garystafford/consul-agent:latest garystafford/consul-agent:0.1
docker push garystafford/consul-agent:latest
docker push garystafford/consul-agent:0.1

docker build -t garystafford/consul-server:latest .
docker tag garystafford/consul-server:latest garystafford/consul-server:0.1
docker push garystafford/consul-server:latest
docker push garystafford/consul-server:0.1
```
