#!/bin/bash
# Remove puppet 2.7.19 which is installed on this basebox
gem uninstall puppet -v '2.7.19'
gem uninstall facter -v '1.6.17'
# Install a decent version of Facter and Librarian-Puppet from Gems
gem install --no-rdoc --no-ri --version "0.9.8" librarian-puppet
gem install --no-rdoc --no-ri --version "1.7.1" facter
