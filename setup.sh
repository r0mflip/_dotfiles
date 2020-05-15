#!/usr/bin/env bash

# utilities
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

  src_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P)/src"
  dst_dir="${1:-$HOME}"

  if [ ! -d "$src_dir/$OS" ]; then
    echo >&2 "=> Installer not found for '$OS'"
    exit 2
  fi

  echo ""
  echo "=> Set destination to '$dst_dir'"
  echo "=> Running installer for '$OS'"
  echo ""

  "$src_dir/$OS/main.sh" "$src_dir" "$dst_dir"

  echo ""
  echo "=> Close and reopen your terminal allowing"
  echo "=> the changes to take effect"
  echo ""

  return
}

main "$@"
