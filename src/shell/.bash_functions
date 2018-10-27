#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Create new directories and enter the first one.

mkd() {
  if [ -n "$*" ]; then
    mkdir -p "$@"
    #      └─ make parent directories if needed

    cd "$1"
    # change into the first directory

    return $?
    # return the exit status of cd, mkdir is always 0
  fi
}
