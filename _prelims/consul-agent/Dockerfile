# Updated version of gliderlabs/consul-agent Dockerfile
# https://hub.docker.com/r/gliderlabs/consul-agent/~/dockerfile/

FROM garystafford/consul:0.1
LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
COPY agent.json /config/agent.json
EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp
ENV DNS_RESOLVES consul
ENV DNS_PORT 8600
ENTRYPOINT ["/bin/consul", "agent", "-config-dir=/config"]
