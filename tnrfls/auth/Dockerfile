FROM alpine:3.19

RUN apk add --no-cache \
    caddy \
    oauth2-proxy

RUN mkdir -p /auth

COPY Caddyfile /auth/Caddyfile
COPY oauth2-proxy.cfg /auth/oauth2-proxy.cfg
COPY start.sh /auth/start.sh

EXPOSE 8080/tcp
EXPOSE 8443/tcp
EXPOSE 8443/udp

CMD ["/auth/start.sh"]