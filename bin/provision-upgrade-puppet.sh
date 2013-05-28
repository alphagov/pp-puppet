#!/bin/bash
#Patch basebox to remove "stdin is not a tty" errors by removing "mesg n" from this file
echo "" >/root/.profile
# Sleep for 5 seconds to wait for network to come up
sleep 5
echo "... Installing the correct librarian-puppet and facter versions"
# Install a decent version of Facter and Librarian-Puppet from Gems
gem list puppet | grep "3.1.1" >/dev/null || gem install --no-rdoc --no-ri --version "3.1.1" puppet >/dev/null
gem list facter | grep "1.7.1" >/dev/null || gem install --no-rdoc --no-ri --version "1.7.1" facter >/dev/null
gem list librarian-puppet | grep "0.9.8" >/dev/null || gem install --no-rdoc --no-ri --version "0.9.8" librarian-puppet >/dev/null
echo "... Running 'apt-get update'"
apt-get -qq -y update >/dev/null 2>&1
echo "... Installing git"
apt-get -qq -y install git >/dev/null 2>&1
echo "... Installing puppet modules with librarian"
cd /vagrant
librarian-puppet install

