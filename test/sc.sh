#!/usr/bin/env bash


main() {
  # ' At first you're like "shellcheck is awesome" but then you're
  #   like "wtf are we still using bash" '.
  #
  #  (from: https://twitter.com/astarasikov/status/568825996532707330)

  local current_dir
  current_dir="$(pwd)"

  find \
    "$current_dir/install.sh" \
    "$current_dir/src/setup.sh" \
    "$current_dir/src/bash" \
    "$current_dir/test" \
    -type f \
    ! -path "$current_dir/src/shell/inputrc" \
    -exec shellcheck \
      -e SC1090 \
      -e SC1091 \
      -e SC2164 \
    {} +

  local code=$?

  return $code
}

main
