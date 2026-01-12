FROM alpine:3.19

RUN apk add --no-cache openjdk17-jre-headless
RUN mkdir -p /app

COPY app.conf /app/app.conf
COPY start.sh /app/start.sh

EXPOSE 25565/tcp
EXPOSE 24454/udp

CMD ["/app/start.sh"]