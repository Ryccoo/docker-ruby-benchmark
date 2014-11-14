FROM ryccoo/docker-base-rvm:latest
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get install -y openjdk-7-jdk
RUN /bin/bash -lc 'rvm install jruby-head'
