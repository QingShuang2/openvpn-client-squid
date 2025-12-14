FROM alpine:latest
RUN /bin/sh -c true \
    && apk add --update-cache squid openvpn bash \
    && rm -rf /var/cache/apk/* && true
ENTRYPOINT [ "/bin/bash", "-c", "cd /etc/openvpn && /usr/sbin/openvpn --config *.conf & rm -rf /var/run/squid.pid && squid -N" ]