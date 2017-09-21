FROM ubuntu:xenial

MAINTAINER Filiosoft Open Source <opensource@filiosoft.com>

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl apt-transport-https default-jdk git && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://get.mcpr.io/debian/ nightly main" > /etc/apt/sources.list.d/mcpr.list && \
    curl -sk https://get.mcpr.io/debian/pubkey.gpg | apt-key add - && \
    apt-get update && \
    apt-get install --no-install-recommends -y mcpr-cli && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /minecraft
WORKDIR /minecraft