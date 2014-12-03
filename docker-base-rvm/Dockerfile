FROM ubuntu:14.04
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV HOME /root
ENV SHELL /bin/bash
WORKDIR /home

RUN apt-get update
RUN apt-get install -y curl git

RUN \curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -L https://get.rvm.io | bash -s stable
RUN \source /etc/profile.d/rvm.sh

RUN echo "export PATH=\"$PATH:/usr/local/rvm/bin\"" > .bashrc
RUN echo "source /usr/local/rvm/scripts/rvm" > .bashrc

RUN /bin/bash -l -c "rvm requirements"

RUN git clone https://github.com/Ryccoo/docker-ruby-benchmark.git

WORKDIR /home/docker-ruby-benchmark
