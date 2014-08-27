#!/bin/bash -ex

# This script is run by Travis after the current commit passes all the tests.
# It creates the following tags and pushes them to the repo:
# - release_<travis build number>
# - release
#
# This requires a GitHub token with permission to write to the repo.


##### TESTING LOCALLY #####

# To test locally we need to fake the environment variables provided by Travis.
#
# Do this by setting LOCAL_TEST_MODE to "true" and TESTING_GITHUB_TOKEN to a
# token you create in github with ``public_repo`` permission.


LOCAL_TEST_MODE="false"
TESTING_GITHUB_TOKEN="make-yourself-one-in-github"


##### RUNNING IN TRAVIS #####

# When running in Travis the GH_TOKEN variable is set by Travis itself by
# decrypting the ``secure`` section from the .travis.yml file

# To create a new token, follow these steps:
#
# - create a new token in GitHub with the ``public_repo`` permission
#   (preferably as gds-ci-pp user)
# - /var/apps/stagecraft
# - sudo gem install travis
# - travis encrypt --add GH_TOKEN=the-token-from-github

# For Travis encrypted environment variables, see:
# - http://docs.travis-ci.com/user/encryption-keys/

# Get the public key of your repo with:
# - https://api.travis-ci.org/repos/alphagov/stagecraft/key

# For Travis environment variables, see
# http://docs.travis-ci.com/user/ci-environment/

# For a similar example of working with Github and Travis, see:
# - http://benlimmer.com/2013/12/26/automatically-publish-javadoc-to-gh-pages-with-travis-ci/

function ensure_running_in_travis_master_branch {

  if [ "$TRAVIS" != "true" ]; then
      echo "Not running outside of Travis."
      exit 1
  fi

  if [ "$TRAVIS_BRANCH" != "master" ]; then
      echo "Not pushing release tag, not on Travis master."
      exit 2
  fi
}

function ensure_only_tagging_on_production_ruby_version {
  if [ "${TRAVIS_RUBY_VERSION}" != "1.9.3" ]; then
    echo "No release tagging for Ruby version ${TRAVIS_RUBY_VERSION}"
    exit 3
  fi
}

function make_temp_repo_directory {
  TMP_REPO_DIR=$(mktemp --directory --suffix _travis_${TRAVIS_BUILD_NUMBER})
}

function clone_repo {
  turn_off_bash_echo
  git clone https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG} ${TMP_REPO_DIR}
  turn_on_bash_echo
}

function turn_off_bash_echo {
  set +x
}

function turn_on_bash_echo {
  set -x
}

function make_release_tag_from_travis_build_number {
  pushd ${TMP_REPO_DIR}

  git checkout ${TRAVIS_COMMIT}
  git tag "${RELEASE_BRANCH_NAME}_${TRAVIS_BUILD_NUMBER}"
  git push origin --tags --quiet

  git tag --force "${RELEASE_BRANCH_NAME}"
  git push --force origin --tags --quiet

  popd
}

function setup_fake_travis_environment {
  echo "Setting up fake Travis environment"
  TRAVIS="true"
  TRAVIS_REPO_SLUG="alphagov/pp-puppet"
  TRAVIS_BRANCH="master"
  TRAVIS_COMMIT="a4460728d9cdd80717e49ffb0a2a70817d39dcdb"
  TRAVIS_BUILD_NUMBER="123456789"
  TRAVIS_RUBY_VERSION="1.9.3"
  GH_TOKEN="${TESTING_GITHUB_TOKEN}"
}

if [ "${LOCAL_TEST_MODE}" == "true" ]; then
    setup_fake_travis_environment
    RELEASE_BRANCH_NAME="release_testing"
else
    RELEASE_BRANCH_NAME="release"
fi



ensure_running_in_travis_master_branch
ensure_only_tagging_on_production_ruby_version
make_temp_repo_directory
clone_repo
make_release_tag_from_travis_build_number

