FROM mitmproxy/mitmproxy:latest
MAINTAINER  Jessica Stokes <hello@jessicastokes.net>

WORKDIR /tmp/workdir

ENV OPENSSL_VERSION=1.1.1g

RUN apk add curl perl && \
    curl -sLO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xvfz "openssl-${OPENSSL_VERSION}.tar.gz" && \
    apk del openssl

# OpenSSL configuration borrowed from Alpine's own package https://git.alpinelinux.org/aports/tree/main/openssl/APKBUILD
RUN cd "openssl-${OPENSSL_VERSION}" && \
    ./Configure \
      --prefix=/usr \
      --libdir=lib \
      --openssldir=/etc/ssl \
      shared no-zlib \
      no-async no-comp no-idea no-mdc2 no-rc5 no-ec2m \
      no-sm2 no-sm4 no-ssl2 no-ssl3 no-seed \
      no-weak-ssl-ciphers -Wa,--noexecstack

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 8081

CMD ["mitmproxy"]
