FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive
RUN { \
    echo "deb http://deb.debian.org/debian/ bullseye main contrib non-free" ; \
    echo "deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free" ; \
    echo "deb http://security.debian.org/ bullseye-security main contrib non-free" ; \
    } > /etc/apt/sources.list \
 && apt-get -y update \
 && apt-get -y install eatmydata \
 && { echo '#!/bin/sh' ; echo 'exec eatmydata /usr/bin/apt-get -y "$@"'; } > /usr/local/bin/apt-get \
 && chmod +x /usr/local/bin/apt-get \
 && hash -r \
 && apt-get -y dist-upgrade \
 && apt-get -y --no-install-recommends install \
      autoconf \
      automake \
      bison \
      build-essential \
      ca-certificates \
      cmake \
      debhelper \
      fakeroot \
      flex \
      git \
      gpg \
      less \
      linux-headers-amd64 \
      openssl \
      pkg-config \
      sudo \
      wget \
      yasm


COPY certs/*.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

RUN useradd -d /build -m -r -s /bin/bash -U builder \
 && mkdir -p /output /src \
 && echo 'builder ALL = NOPASSWD: ALL' > /etc/sudoers.d/superbuilder

USER builder
WORKDIR /build
