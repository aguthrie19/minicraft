# Stage 1: use temp container to install and verify binary
FROM alpine:3.19 AS installer
ARG SRV_VERSION=1.21.11

RUN apk add --no-cache tar ca-certificates curl jq
WORKDIR /tmp
RUN SRV_VERSION_INFO=$(curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' \
    | jq --arg VERSION "$SRV_VERSION" --raw-output '[.versions[]|select(.id == $VERSION)][0].url') \
    && DNLD_URL=$(curl -fsSL "$SRV_VERSION_INFO" \
    | jq -r '.downloads.server.url') \
    && curl -fsSL "$DNLD_URL" -o /tmp/server.jar

# Stage 2: make real container and copy
FROM alpine:3.19

RUN apk add --no-cache openjdk21-jre-headless rcon
RUN mkdir -p /app

COPY --from=installer /tmp/server.jar /app/server.jar
COPY app.conf /app/app.conf
COPY start.sh /app/start.sh

RUN chmod +x /app/server.jar

EXPOSE 25565/tcp
EXPOSE 24454/udp

CMD ["/app/start.sh"]
