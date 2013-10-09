# Install ruby-build
cd /home/vagrant
git clone git://github.com/sstephenson/ruby-build.git
cd ruby-build
./install.sh

# Install ruby 1.9.3
ruby-build 1.9.3-p448 /opt/rubies/ruby-1.9.3-p448

cd /home/vagrant
wget -O chruby-0.3.7.tar.gz https://github.com/postmodern/chruby/archive/v0.3.7.tar.gz
tar -xzvf chruby-0.3.7.tar.gz
cd chruby-0.3.7/
sudo make install

# Set default ruby
echo "source /usr/local/share/chruby/chruby.sh \nchruby ruby-1.9.3" | sudo tee /etc/profile.d/chruby.sh

export RUBYCMD="source /usr/local/share/chruby/chruby.sh && chruby ruby-1.9.3"

# Installing chef & Puppet
#gem install chef --no-ri --no-rdoc
sudo /bin/bash -c "$RUBYCMD && gem install puppet --no-ri --no-rdoc"