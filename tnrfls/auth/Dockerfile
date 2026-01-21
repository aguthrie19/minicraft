# Stage 1: use a temporary container to install and verify the binary

FROM alpine:3.19 AS installer

ARG VERSION=v7.14.2
ARG ARCH=linux-amd64
ARG OAUTH2_PROXY_URL="https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${VERSION}/oauth2-proxy-${VERSION}.${ARCH}.tar.gz"
ARG OAUTH2_PROXY_CSM="https://github.com/oauth2-proxy/oauth2-proxy/releases/download/${VERSION}/oauth2-proxy-${VERSION}.${ARCH}.tar.gz-sha256sum.txt"

RUN apk add --no-cache tar ca-certificates curl

WORKDIR /tmp

RUN curl -fsSL "$OAUTH2_PROXY_URL" -o /tmp/oauth2-proxy.tar.gz \
    && curl -fsSL "$OAUTH2_PROXY_CSM" -o /tmp/sha256sum.txt

RUN echo "$(awk '{print $1}' /tmp/sha256sum.txt)  /tmp/oauth2-proxy.tar.gz" | sha256sum -cs -
RUN tar -xzf /tmp/oauth2-proxy.tar.gz --strip-components=1
#executables name is "oauth2-proxy" by default

# Stage 2: make your real container and copy the binary from the temporary one
FROM alpine:3.19

ENV XDG_DATA_HOME=/auth/data

RUN apk add --no-cache caddy

# copy binary
COPY --from=installer /tmp/oauth2-proxy /usr/bin/oauth2-proxy
RUN chmod +x /usr/bin/oauth2-proxy

RUN mkdir -p /auth && mkdir -p $XDG_DATA_HOME

COPY Caddyfile /auth/Caddyfile
COPY oauth2-proxy.cfg /auth/oauth2-proxy.cfg
COPY start.sh /auth/start.sh

EXPOSE 8080/tcp
EXPOSE 8443/tcp
EXPOSE 8443/udp

CMD ["/auth/start.sh"]
