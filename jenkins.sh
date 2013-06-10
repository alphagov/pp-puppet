#!/bin/bash

set -xe
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec librarian-puppet install --strip-dot-git
bundle exec rake test
# Remove old debfiles
rm -rf build/*
bundle exec rake deb
