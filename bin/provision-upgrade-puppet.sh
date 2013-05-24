#!/bin/bash
echo "... Installing the correct librarian-puppet and facter versions"
# Remove puppet 2.7.19 which is installed on this basebox
gem uninstall puppet -v '2.7.19' >/dev/null
gem uninstall facter -v '1.6.17' >/dev/null
# Install a decent version of Facter and Librarian-Puppet from Gems
gem install --no-rdoc --no-ri --version "0.9.8" librarian-puppet >/dev/null
gem install --no-rdoc --no-ri --version "1.7.1" facter >/dev/null
