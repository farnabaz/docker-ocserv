FROM alpine

MAINTAINER ilanyu <lanyu19950316@gmail.com>

RUN apk add --update --no-cache curl musl-dev iptables libev openssl gnutls-dev readline-dev libnl3-dev lz4-dev libseccomp-dev gnutls-utils gpgme libseccomp-dev linux-headers linux-pam-dev libev-dev readline-dev tzdata

RUN buildDeps="xz tar openssl gcc autoconf make g++"; \
	set -x \
	&& apk add $buildDeps \
	&& cd \
	&& wget ftp://ftp.infradead.org/pub/ocserv/ocserv-1.1.0.tar.xz \
	&& tar xJf ocserv-1.1.0.tar.xz \
	&& rm -fr ocserv-1.1.0.tar.xz \
	&& cd ocserv-1.1.0 \
	&& sed -i '/#define DEFAULT_CONFIG_ENTRIES /{s/96/200/}' src/vpn.h \
	&& ./configure \
	&& make \
	&& make install \
	&& mkdir -p /etc/ocserv \
	&& cp ./doc/sample.config /etc/ocserv/ocserv.conf \
	&& cd \
	&& rm -fr ./ocserv-1.1.0 \
	&& apk del --purge $buildDeps

RUN set -x \
	&& sed -i 's/tcp-port = 443/tcp-port = 4443/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/udp-port = 443/udp-port = 4443/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/\.\/sample\.passwd/\/etc\/ocserv\/ocpasswd/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/#\(stats-report-time.*\)/\1/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/#\(tunnel-all-dns.*\)/\1/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/#\(persistent-cookies.*\)/\1/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/predictable-ips = true/predictable-ips = false/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/cookie-timeout = 300/cookie-timeout = 3600/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/min-reauth-time = 300/min-reauth-time = 10/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/auth-timeout = 240/auth-timeout = 360/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/dpd = 90/dpd = 45/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/mobile-dpd = 1800/mobile-dpd = 60/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/max-clients = 16/max-clients = 0/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/max-same-clients = 2/max-same-clients = 0/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/\.\.\/tests/\/etc\/ocserv/' /etc/ocserv/ocserv.conf \
	&& sed -i '/^ipv4-network = /{s/192.168.1.0/10.9.0.0/}' /etc/ocserv/ocserv.conf \
	&& sed -i 's/192.168.1.2/8.8.8.8/' /etc/ocserv/ocserv.conf \
	&& sed -i 's/^route/#route/' /etc/ocserv/ocserv.conf \
	&& sed -i 's#server-cert = /etc/ocserv/certs/server-cert-secp521r1.pem#server-cert = /etc/ocserv/certs/server-cert.pem#' /etc/ocserv/ocserv.conf \
	&& sed -i 's#server-key = /etc/ocserv/certs/server-key-secp521r1.pem#server-key = /etc/ocserv/certs/server-key.pem#' /etc/ocserv/ocserv.conf \
	&& sed -i 's/^no-route/#no-route/' /etc/ocserv/ocserv.conf

WORKDIR /etc/ocserv

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 4443
CMD ["ocserv", "-c", "/etc/ocserv/ocserv.conf", "-f", "-d" ,"1"]
