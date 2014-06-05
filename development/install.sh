#!/bin/sh

GITHUB_PUBLIC="https://github.com/alphagov"
GITHUB_ENT="git@github.gds:gds"

##############################################################################

set -e

ANSI_GREEN="\033[32m"
ANSI_RED="\033[31m"
ANSI_YELLOW="\033[33m"
ANSI_RESET="\033[0m"
ANSI_BOLD="\033[1m"
SUDO_COMMAND="sudo"

status () {
  echo "---> ${@}" >&2
}

abort () {
  echo "$@" >&2
  exit 1
}

ok () {
  echo "${ANSI_GREEN}${ANSI_BOLD}OK:${ANSI_RESET} ${ANSI_GREEN}${@}${ANSI_RESET}" >&2
}

warn () {
  echo "${ANSI_YELLOW}${ANSI_BOLD}WARNING:${ANSI_RESET} ${ANSI_YELLOW}${@}${ANSI_RESET}" >&2
}

error () {
  echo "${ANSI_RED}${ANSI_BOLD}ERROR:${ANSI_RESET} ${ANSI_RED}${@}${ANSI_RESET}" >&2
}

fetch_repo () {
  if [ -e "../../$1" ]; then
    if [ ! -d "../../$1/.git" ]; then
      warn "Skipping $1 - dir exists but is not a git repo"
    else
      ok "Skipping $1 - already cloned"
    fi
  else
    attempts=0
    until git clone -q "${2}/${1}.git" ../../${1}|| [ $attempts -gt 3 ]; do
      warn "Failing $1 - trying again in a moment."
      sleep 2
      attempts=`expr $attempts + 1`
      if [ $attempts -eq 3 ]; then
        # We've tried 3 times - skip this repo. Perhaps it's been renamed?
        attempts=4
      fi
    done
    if [ $attempts -eq 4 ]; then
      warn "Failed $1 - clone failed, skipping"
    else
      ok "Cloned $1"
    fi
  fi
}

check_installed () {
  if which $1 >/dev/null 2>&1; then
      ok "Found $1 program"
  else
      abort "Could not find $1 program"
  fi
}

if [ "$(id -u)" -eq "0" ]; then
  abort "This script is not intended to be run as root. Rerun without su/sudo."
fi


status "Checking prerequisite software"
check_installed git
check_installed vagrant

status "Reading list of public repositories from GH_REPOS and fetching from GitHub"
while read repo; do
  fetch_repo "$repo" "$GITHUB_PUBLIC"
done < "GH_REPOS"

if [ -n "$ENT_DEPS" ]; then
    status "Reading list of private repositories from GHE_REPOS and fetching from GitHub Enterprise"
    while read repo; do
      fetch_repo "$repo" "$GITHUB_ENT"
    done < "GHE_REPOS"
fi

if [ -n "$GOVUK_DEPS" ]; then
    status "Reading list of GOV.UK repositories from GOV_REPOS and fetching from GitHub"
    while read repo; do
        fetch_repo "$repo" "$GITHUB_PUBLIC"
    done < "GOV_REPOS"
fi

