#!/usr/bin/env bash

# see https://github.com/nvm-sh/nvm/

{ # this ensures the entire script is downloaded #

dot_latest_version="v0.1.1"

dot_temp_dir="$(mktemp -d /tmp/XXXXX)"

# source url
dot_source="https://github.com/r0mflip/_dotfiles.git"

# download from git to temp dir
download_dot_from_git() {
  local DOWNLOAD_DIR
  DOWNLOAD_DIR="$dot_temp_dir"

  # cloning to $DOWNLOAD_DIR
  echo "=> Downloading _dotfiles from git to '$DOWNLOAD_DIR'"

  command git init "${DOWNLOAD_DIR}" || {
    echo >&2 '   Failed to initialize repo. Please report this!'
    exit 2
  }

  command git --git-dir="${DOWNLOAD_DIR}/.git" remote add origin "$dot_source" 2>/dev/null \
    || command git --git-dir="${DOWNLOAD_DIR}/.git" remote set-url origin "$dot_source" || {
    echo >&2 '   Failed to add remote "origin" (or set the URL). Please report this!'
    exit 2
  }

  command git --git-dir="${DOWNLOAD_DIR}/.git" fetch origin tag "$dot_latest_version" --depth=1 || {
    echo >&2 '   Failed to fetch origin with tags. Please report this!'
    exit 2
  }

  command git -c advice.detachedHead=false --git-dir="$DOWNLOAD_DIR"/.git --work-tree="$DOWNLOAD_DIR" checkout -f --quiet "$dot_latest_version"

  if [ -n "$(command git --git-dir="$DOWNLOAD_DIR"/.git --work-tree="$DOWNLOAD_DIR" show-ref refs/heads/master)" ]; then
    command git --git-dir="$DOWNLOAD_DIR"/.git --work-tree="$DOWNLOAD_DIR" branch --quiet -D master >/dev/null 2>&1
  fi

  return
}

dot_do_install() {
  # download repo to temp dir
  download_dot_from_git

  echo

  # run setup script
  # shellcheck source=/dev/null
  echo "=> Running setup..."
  command bash "$dot_temp_dir/src/setup.sh" "$dot_temp_dir" || {
    echo >&2 "=> Setup failed!"
    exit 3
  }

  dot_reset
  echo

  return
}

# remove functions and variables
dot_reset() {
  unset -f dot_temp_dir dot_latest_version dot_do_install \
    download_dot_from_git dot_reset
}

dot_do_install

} # this ensures the entire script is downloaded #
