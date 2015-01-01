FROM ubuntu:14.04
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV HOME /root
ENV SHELL /bin/bash
WORKDIR /home

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV FLAGS "-march=native -O2"

RUN apt-get update
RUN apt-get install -y curl git autoconf make software-properties-common python-software-properties bison ruby zlib1g-dev libssl-dev \
    && mkdir -p /usr/src/ruby

RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update \
    && apt-get install -y gcc-4.9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 20 \
    && update-alternatives --config gcc
