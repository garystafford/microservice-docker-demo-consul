# Updated version of gliderlabs/consul Dockerfile
# https://hub.docker.com/r/gliderlabs/consul/~/dockerfile/

FROM alpine:3.5
LABEL maintainer "Gary A. Stafford <garystafford@rochester.rr.com>"
ENV CONSUL_VERSION 0.7.4
ENV CONSUL_SHA256 23a61773bee9b29198cc1f8fe2e62c320f82f95006ff70840c15c1e58eead73b

RUN apk --no-cache add curl ca-certificates \
    && curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o /tmp/consul.zip \
    && echo "${CONSUL_SHA256}  /tmp/consul.zip" > /tmp/consul.sha256 \
    && sha256sum -c /tmp/consul.sha256 \
    && cd /bin \
    && unzip /tmp/consul.zip \
    && chmod +x /bin/consul \
    && rm /tmp/consul.zip

ENTRYPOINT ["/bin/consul"]
