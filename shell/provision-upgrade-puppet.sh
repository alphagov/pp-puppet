#!/bin/bash
# Remove the system version of Puppet
apt-get -y remove puppet puppet-common facter
# Install a decent version of Puppet from Gems
gem install --no-rdoc --no-ri --version "3.1.1" puppet
gem install --no-rdoc --no-ri --version "0.9.8" librarian-puppet
gem install --no-rdoc --no-ri --version "1.7.1" facter
