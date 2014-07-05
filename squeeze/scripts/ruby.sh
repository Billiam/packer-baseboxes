#!/bin/bash -x
set -e

# Install ruby-build
cd /home/vagrant
wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
tar -xzvf ruby-install-0.4.3.tar.gz
cd ruby-install-0.4.3/
sudo make install

# Install ruby 2.1.2
ruby-install ruby 2.1.2

# Cleanup source installation
cd /usr/local/src
sudo rm -r ruby-*

cd /home/vagrant
wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
sudo make install

# Set default ruby
echo "source /usr/local/share/chruby/chruby.sh \nchruby ruby-2.1.2" | sudo tee /etc/profile.d/chruby.sh

export RUBYCMD="source /usr/local/share/chruby/chruby.sh && chruby ruby-2.1.2"

# Installing Puppet
sudo /bin/bash -c "$RUBYCMD && gem install puppet --no-ri --no-rdoc"