#!/bin/bash -e

function install_puppet {
    bundle exec librarian-puppet install
}

install_puppet
