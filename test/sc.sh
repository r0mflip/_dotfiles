#!/usr/bin/env bash

declare current_dir="$(pwd)"

main() {
  # ' At first you're like "shellcheck is awesome" but then you're
  #   like "wtf are we still using bash" '.
  #
  #  (from: https://twitter.com/astarasikov/status/568825996532707330)

  find \
    "$current_dir/init.sh" \
    "$current_dir/src/setup.sh" \
    "$current_dir/src/shell" \
    "$current_dir/test" \
    -type f \
    ! -path "$current_dir/src/shell/inputrc" \
    -exec shellcheck \
      -e SC1090 \
      -e SC1091 \
      -e SC2155 \
      -e SC2164 \
    {} +

  local code=$?

  if [ $code -eq 0 ]; then
    printf "\nEverything's fine\n"
  else
    printf "\nUh oh... something's wrong\n"
  fi

  return $code
}

main

unset -f main
