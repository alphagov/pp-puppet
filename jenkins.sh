#!/bin/bash

set -xe
# Install gems in bundler
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
# Run librarian puppet to download modules
bundle exec librarian-puppet install --strip-dot-git
# RUN ALL THE TESTS
bundle exec rake test
# Remove old debfiles
rm -rf build/*
# Build the tar package
bundle exec rake tar
echo "Built package version ${BUILD_NUMBER}: pp_puppet.tar.gz"
