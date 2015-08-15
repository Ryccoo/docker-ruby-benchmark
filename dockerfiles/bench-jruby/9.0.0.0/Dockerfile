FROM ryccoo/rvm:latest
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y openjdk-7-jdk --fix-missing
RUN /bin/bash -lc 'rvm get head'
RUN /bin/bash -lc 'rvm install jruby-9.0.0.0'
