FROM alpine:3.2
MAINTAINER Calvin Leung Huang <https://github.com/cleung2010>

RUN apk --update add nodejs git openssh && \
    rm -rf /var/cache/apk/* && \
    npm install git2consul@0.12.10 --global && \
    mkdir -p /etc/git2consul.d

ENTRYPOINT [ "/bin/sh","-c","echo \"$G2C_CFG\" > /etc/git2consul.d/config.json; exec /usr/bin/node /usr/lib/node_modules/git2consul" ]
