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

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN /bin/bash -l -c "rvm get head"

WORKDIR /home
