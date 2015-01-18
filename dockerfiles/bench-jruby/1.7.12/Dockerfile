FROM ryccoo/rvm:latest
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y openjdk-7-jdk --fix-missing
RUN /bin/bash -lc 'rvm install jruby-1.7.12'
