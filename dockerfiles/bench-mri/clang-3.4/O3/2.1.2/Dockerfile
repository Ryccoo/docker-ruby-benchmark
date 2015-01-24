FROM ryccoo/clang:3.4
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

ENV RUBY_MAJOR 2.1
ENV RUBY_VERSION 2.1.2

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    		| tar -xjC /usr/src/ruby

RUN cd /usr/src/ruby/ruby-$RUBY_VERSION \
    && autoconf \
    && ./configure --disable-install-doc --with-gcc=clang \
    && make \
    && apt-get purge -y --auto-remove bison ruby \
    && make install