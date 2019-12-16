#!/usr/bin/env bash

# utilities
be_sudo() {

  sudo -v &> "/dev/null"

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588

  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &> "/dev/null" &

}


get_os() {

  local os=""
  local kernelName=""

  kernelName="$(uname -s)"

  if [ "$kernelName" == "Darwin" ]; then
    os="macos"
  elif [ "$kernelName" == "Linux" ] && \
    [ -e "/etc/os-release" ]; then
    os="$(. /etc/os-release; printf "%s" "$ID")"
  else
    os="$kernelName"
  fi

  printf "%s" "$os"

}


# run installer for the specific OS
main() {

  local OS
  OS="$(get_os)"

  local_src_dir="$PWD"
  src_dir="${1:-$local_src_dir}/src"

  if [ ! -d "$src_dir/$OS" ]; then
    echo >&2 "=> Installer not found for '$OS'"
    exit 2
  fi

  echo "=> Running installer for '$OS'"

  "$src_dir/$OS/main.sh"

  echo
  echo "=> Close and reopen your terminal allowing"
  echo "=> the changes to take effect"
  echo

  return

}

main "$@"
