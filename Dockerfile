FROM alpine:3.2
MAINTAINER Calvin Leung Huang <https://github.com/cleung2010>

RUN apk --update add nodejs git && \
    rm -rf /var/cache/apk/* && \
    npm install git2consul --global && \
    mkdir -p /etc/git2consul.d

COPY ./docker-entrypoint.sh /

EXPOSE 8500


ENTRYPOINT [ "./docker-entrypoint.sh" ]
