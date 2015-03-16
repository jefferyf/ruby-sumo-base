FROM debian:jessie
MAINTAINER Jeff Miller <jeffery.f@gmail.com>

RUN apt-get update && apt-get install -y \
  build-essential \
  python-software-properties \
  software-properties-common \
  git \
  npm \
  wget \
  curl \
  libssl-dev \
  zlib1g-dev\
  libreadline6-dev \
  libyaml-dev \
  libffi-dev \
  libpq-dev \
  libxml2-dev \
  libxslt1-dev \
  libqt4-webkit \
  libqt4-dev \
  libmysqlclient-dev \
  xvfb

# Install Rbenv
RUN git clone git://github.com/sstephenson/rbenv.git /root/.rbenv
RUN echo 'export PATH="/root/.rbenv/bin:$PATH"' >> /root/.bashrc
RUN exec $SHELL

# Install Ruby-Build
RUN git clone git://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN /root/.rbenv/plugins/ruby-build/install.sh
RUN exec $SHELL

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh # or /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Expose Rbenv
ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH

# Setup Rbenv
RUN rbenv install 2.2.1
RUN rbenv local 2.2.1
RUN rbenv global 2.2.1
RUN gem install bundler
RUN rbenv rehash

# Configure Gems
RUN echo "gem: --no-ri --no-rdoc" > /root/.gemrc

# Install NodeJS
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get clean

# Install Rails
RUN gem install rails

RUN wget -q -O /tmp/collector.deb https://s3-us-west-2.amazonaws.com/jssumo/sumocollector_19.110-9_amd64.deb
RUN dpkg -i /tmp/collector.deb
RUN rm /tmp/collector.deb

RUN apt-get remove --quiet --force-yes -y wget \
  build-essential \
  python-software-properties \
  software-properties-common
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
