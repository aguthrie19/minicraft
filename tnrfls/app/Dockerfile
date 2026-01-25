FROM alpine:3.19
ARG DKFDIR=tnrfls/app
WORKDIR /app

RUN apk add --no-cache openjdk21-jre-headless rcon ca-certificates curl jq zip
RUN wget -O ferium-linux-nogui.zip https://github.com/gorilla-devs/ferium/releases/download/v4.7.1/ferium-linux-nogui.zip \
    && unzip ferium-linux-nogui.zip -d /bin/



COPY --chmod=640 ${DKFDIR}/app.conf /app/app.conf
COPY --chmod=770 ${DKFDIR}/ferium_profile.json /app/ferium_profile.json
COPY --chmod=750 ${DKFDIR}/beetroot_soup.json /app/beetroot_soup.json
COPY --chmod=750 ${DKFDIR}/health_gain.json /app/health_gain.json
COPY --chmod=750 ${DKFDIR}/default_settings.mcfunction /app/default_settings.mcfunction
COPY --chmod=750 ops/hlpr_get_minecraft.sh /app/hlpr_get_minecraft.sh
COPY --chmod=750 ops/hlpr_get_mods.sh /app/hlpr_get_mods.sh
COPY --chmod=750 ${DKFDIR}/boat_craft_1.0.0.zip /app/boat_craft_1.0.0.zip
COPY --chmod=750 ${DKFDIR}/start.sh /app/start.sh


EXPOSE 25565/tcp
EXPOSE 24454/udp

ENV SRVTYPE="fabric"
ENTRYPOINT [ "/app/start.sh" ]
