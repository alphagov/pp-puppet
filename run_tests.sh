#!/bin/bash -e

set -o pipefail

bundle exec rake || echo "FAIL." && false
