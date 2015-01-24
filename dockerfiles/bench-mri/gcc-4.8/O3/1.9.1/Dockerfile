FROM ryccoo/gcc-4.8
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

ENV RUBY_MAJOR 1.9
ENV RUBY_VERSION 1.9.1-p431

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    		| tar -xjC /usr/src/ruby

RUN cd /usr/src/ruby/ruby-$RUBY_VERSION \
    && apt-get remove -y libssl-dev \
    && autoconf \
    && ./configure --disable-install-doc \
    && make \
    && apt-get purge -y --auto-remove bison ruby \
    && make install

