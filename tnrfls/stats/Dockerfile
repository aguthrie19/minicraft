FROM alpine:3.19

RUN apk add --no-cache \
    wget \    
    ttyd \
    php82-fpm \
    php82-session \
    php82-openssl \
    php82-json \
    php82-posix \
    php82-ctype \
    php82-fileinfo \
    php82-mbstring \
    php82-iconv \
    php82-zip \
    podman-remote
#    mtm

RUN mkdir -p /stats/tfm && \
    wget -O /stats/tfm/tfm.php \
      https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php

COPY fpm_tfm_pool.conf /stats/tfm/fpm_tfm_pool.conf
COPY tfm_config.php /stats/tfm/config.php
COPY start.sh /stats/start.sh

EXPOSE 9000/tcp
EXPOSE 7681/tcp

CMD ["/stats/start.sh"]
