FROM ryccoo/gcc-4.8
MAINTAINER Richard Ludvigh "https://github.com/Ryccoo"

ENV RUBY_MAJOR 1.8
ENV RUBY_VERSION 1.8.6-p420

RUN curl -SL "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    		| tar -xjC /usr/src/ruby

RUN cd /usr/src/ruby/ruby-$RUBY_VERSION \
    && apt-get remove -y libssl-dev \
    && autoconf \
    && ./configure optflags='-O3' --disable-install-doc \
    && make \
    && apt-get purge -y --auto-remove bison ruby \
    && make install