FROM ryccoo/gcc-4.9:O2
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

ENV RUBY_MAJOR 2.1
ENV RUBY_VERSION 2.1.0

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    		| tar -xjC /usr/src/ruby

RUN cd /usr/src/ruby/ruby-$RUBY_VERSION \
    && autoconf \
    && export CFLAGS="-march=native -g -O2" \
    && ./configure optflags='-march=native -g -O2' --disable-install-doc \
    && make \
    && apt-get purge -y --auto-remove bison ruby \
    && make install