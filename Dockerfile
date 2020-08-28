FROM mitmproxy/mitmproxy:latest
MAINTAINER  Jessica Stokes <hello@jessicastokes.net>

WORKDIR /tmp/workdir

ENV OPENSSL_VERSION=1.1.1g

RUN apk --no-cache add --virtual .build-dependencies linux-headers build-base curl perl && \
    curl -sLO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
    tar xvfz "openssl-${OPENSSL_VERSION}.tar.gz" && \
    apk del openssl libssl libcrypto

# OpenSSL configuration borrowed from Alpine's own package https://git.alpinelinux.org/aports/tree/main/openssl/APKBUILD
RUN cd "openssl-${OPENSSL_VERSION}" && \
    ./config \
      --prefix=/usr \
      --libdir=lib \
      --openssldir=/etc/ssl \
      shared no-zlib \
      no-async no-comp no-idea no-mdc2 no-rc5 no-ec2m \
      no-sm2 no-sm4 enable-ssl2 enable-ssl3 no-seed \
      no-weak-ssl-ciphers -Wa,--noexecstack && \
    make && \
    make install_sw

WORKDIR /

RUN apk del .build-dependencies && \
    rm -rf /tmp/workdir

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080 8081

CMD ["mitmproxy"]
