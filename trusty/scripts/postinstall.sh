#!/bin/bash

# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev libncurses5-dev libffi-dev libxml2-dev libxslt-dev
apt-get -y install vim git ntp ncdu nfs-common
apt-get clean

# Installing the virtualbox guest additions
apt-get -y install dkms
mount -o loop VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions.iso

cd /tmp

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Add puppet user and group
adduser --system --group --home /var/lib/puppet puppet

# Install ruby-install
cd /home/vagrant
wget -O ruby-install-0.4.3.tar.gz https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz
tar -xzvf ruby-install-0.4.3.tar.gz
cd ruby-install-0.4.3/
sudo make install

# Install ruby 1.9.3
sudo ruby-install ruby 1.9.3
# Install ruby 2.1.2
sudo ruby-install ruby 2.1.2

# clean up ruby installations
sudo rm -r /usr/local/src/ruby*

cd /home/vagrant
wget -O chruby-0.3.8.tar.gz https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz
tar -xzvf chruby-0.3.8.tar.gz
cd chruby-0.3.8/
sudo make install

sudo rm -f /home/vagrant/*.gz

# Set default ruby
echo "source /usr/local/share/chruby/chruby.sh \nchruby 2.1.2" | sudo tee /etc/profile.d/chruby.sh

RUBYCMD="source /usr/local/share/chruby/chruby.sh && chruby 2.1.2"

sudo /bin/bash -c "$RUBYCMD && gem install puppet --no-ri --no-rdoc"

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

apt-get clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

#enforce dvorak layout
sed -e 's/^XKBMODEL="SKIP"/XKBMODEL="pc104"/' -e 's/^XKBVARIANT=""/XKBVARIANT="dvorak"/' -e 's/^XKBLAYOUT=""/XKBLAYOUT="us"/' /etc/default/keyboard | sudo tee /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration

#fix slow SSH login
echo 'UseDNS no' | sudo tee -a /etc/ssh/sshd_config
#enable local ssh environment file
echo 'PermitUserEnvironment yes' | sudo tee -a /etc/ssh/sshd_config

#comment out session optional pam_motd.so
sed -e 's/^\(session\s\+optional\s\+pam_motd.so\)/#\1/' /etc/pam.d/login | sudo tee /etc/pam.d/login
sed -e 's/^\(session\s\+optional\s\+pam_motd.so\)/#\1/' /etc/pam.d/sshd | sudo tee /etc/pam.d/sshd

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
