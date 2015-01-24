FROM ryccoo/gcc-4.9
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

ENV RUBY_MAJOR 2.1
ENV RUBY_VERSION 2.1.5

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    		| tar -xjC /usr/src/ruby

RUN cd /usr/src/ruby/ruby-$RUBY_VERSION \
    && autoconf \
    && export CFLAGS="-O2 -fno-fast-math" \
    && ./configure optflags='-O2 -fno-fast-math' --disable-install-doc \
    && make \
    && apt-get purge -y --auto-remove bison ruby \
    && make install