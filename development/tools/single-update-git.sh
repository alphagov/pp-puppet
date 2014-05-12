#!/bin/sh

set -e

ANSI_GREEN="\033[32m"
ANSI_RED="\033[31m"
ANSI_YELLOW="\033[33m"
ANSI_RESET="\033[0m"
ANSI_BOLD="\033[1m"

truncate () {
  local len="$1"
  local str="$2"
  if [ "${#str}" -gt "$len" ]; then
    printf "$str" | awk "{ s=substr(\$0, 1, $len-3); print s \"...\"; }"
  else
    printf "$str"
  fi
}

start () {
  local repo="$1"
  local branch="$2"
  repo=$(truncate 25 "$repo")
  branch=$(truncate 15 "$branch")
  printf "${ANSI_BOLD}%-25s${ANSI_RESET} %-15s " "$repo" "$branch" >&2
}

ok () {
  start "$REPO" "$BRANCH"
  echo "${ANSI_GREEN}${@}${ANSI_RESET}" >&2
}

warn () {
  start "$REPO" "$BRANCH"
  echo "${ANSI_YELLOW}${@}${ANSI_RESET}" >&2
}

error () {
  start "$REPO" "$BRANCH"
  echo "${ANSI_RED}${@}${ANSI_RESET}" >&2
}

catch_errors () {
  out=$(mktemp -t update-git.XXXXXX)
  trap "rm -f '$out'" EXIT

  if ! "$@" >"$out" 2>&1; then
    error "FAILED, with output:"
    cat "$out"
    exit 1
  fi

  rm -f "$out"
}

if [ "$#" -ne "1" ]; then
  echo "Usage: $(basename "$0") <reponame>"
  exit 1
fi

cd "$(dirname "$0")"

REPO="$1"

cd "../../../$REPO"

BRANCH=$(git symbolic-ref HEAD | sed 's|^refs/heads/||')

if [ -f lock ]; then
  warn "skipped: 'lock' file exists"
elif [ "$BRANCH" != "master" ]; then
  warn "skipped: on non-master branch"
elif ! git diff --quiet --ignore-submodules --no-ext-diff; then
  warn "skipped: uncommitted local changes"
else
  catch_errors git fetch origin
  if ! git merge --ff-only origin/master >/dev/null 2>&1; then
    warn "skipped: unpushed local commits"
  else
    catch_errors git clean -df
    ok "ok"
  fi
fi
