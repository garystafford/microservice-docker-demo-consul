# Updated version of gliderlabs/consul-agent Dockerfile
# https://hub.docker.com/r/gliderlabs/consul-server/~/dockerfile/

FROM garystafford/consul-agent:0.1
LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
COPY server.json /config/server.json
COPY agent.json /config/agent.json
ENTRYPOINT ["/bin/consul", "agent", "-server", "-config-dir=/config"]
