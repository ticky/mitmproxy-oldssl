# ffmpegfs in Docker

FROM ubuntu:20.04
MAINTAINER  Jessica Stokes <hello@jessicastokes.net>

WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yq --no-install-recommends \
            ffmpegfs \
            fuse && \
        apt-get autoremove -y && \
        apt-get clean -y

CMD         ["--help"]
ENTRYPOINT  ["ffmpegfs"]

RUN     rm -rf /var/lib/apt/lists/*
