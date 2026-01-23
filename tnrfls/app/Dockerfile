FROM alpine:3.19
ARG DKFDIR=tnrfls/app
WORKDIR /app

RUN apk add --no-cache openjdk21-jre-headless rcon ca-certificates curl jq zip
RUN wget -O ferium-linux-nogui.zip https://github.com/gorilla-devs/ferium/releases/download/v4.7.1/ferium-linux-nogui.zip \
    && unzip ferium-linux-nogui.zip -d /bin/



COPY --chmod=640 ${DKFDIR}/app.conf /app/app.conf
COPY --chmod=750 ${DKFDIR}/start.sh /app/start.sh
#COPY --chmod=750 ${DKFDIR}/ferium_profile.json /share/minicraftsrv/ferium_profile.json
COPY --chmod=750 ops/hlpr_get_minecraft.sh /app/hlpr_get_minecraft.sh
COPY --chmod=750 ops/hlpr_get_mods.sh /app/hlpr_get_mods.sh

EXPOSE 25565/tcp
EXPOSE 24454/udp

ENV SRVTYPE="fabric"
ENTRYPOINT [ "/app/start.sh" ]
