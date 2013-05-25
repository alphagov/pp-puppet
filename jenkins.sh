#!/bin/bash

set -xe
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

bundle exec librarian-puppet install --strip-dot-git

bundle exec rake deb
