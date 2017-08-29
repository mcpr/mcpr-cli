FROM ubuntu:xenial

MAINTAINER Filiosoft Open Source <opensource@filiosoft.com>

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl apt-transport-https default-jdk git && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb https://apt.filiosoft.com/debian/ nightly main" > /etc/apt/sources.list.d/filiosoft.list && \
    curl -sk https://apt.filiosoft.com/debian/pubkey.gpg | apt-key add - && \
    apt-get update && \
    apt-get install --no-install-recommends -y mcpr-cli && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /minecraft
WORKDIR /minecraft