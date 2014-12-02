FROM ryccoo/docker-base-rvm:latest
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo

ENV SHELL /bin/bash

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update

RUN /bin/bash -lc 'rvm install ruby-2.0.0'
