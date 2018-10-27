#!/bin/bash

declare C_RED=1
declare C_GREEN=2
declare C_CYAN=6

print_in_color() {
  printf "%b" \
    "$(tput setaf "$2" 2> '/dev/null')" \
    "$1" \
    "$(tput sgr0 2> '/dev/null')"
}


set_trap() {
  trap -p "$1" | grep "$2" &> "/dev/null" \
    || trap '$2' "$1"
}


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


execute() {
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"
  local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

  local exitCode=0
  local cmdsPID=""

  # If the current process is ended,
  # also end all its subprocesses.
  set_trap "EXIT" "kill_all_subprocesses"

  # Execute commands in background
  eval "$CMDS" \
    &> "/dev/null" \
    2> "$TMP_FILE" &

  cmdsPID=$!

  # Wait for the commands to no longer be executing
  # in the background, and then get their exit code.
  wait "$cmdsPID" &> "/dev/null"
  exitCode=$?

  # Print output based on what happened.
  if [ $exitCode -eq 0 ]; then
    print_in_color "OK: " $C_GREEN
    printf "%s\n" "$MSG"
  else
    print_in_color "Error: " $C_RED
    printf "%s\n" "$MSG"
  fi

  if [ $exitCode -ne 0 ]; then
    while read -r line; do
     print_in_color "Error: $line" $C_RED
    done < "$TMP_FILE"
  fi

  rm -rf "$TMP_FILE"
  return $exitCode
}


copy_config() {
  declare -a FILES=(
    "git/.gitattributes"            # git
    "git/.gitconfig"
    "git/.gitignore"
    "shell/.bash_aliases"           # bash
    "shell/.bash_autocomplete"
    "shell/.bash_colors"
    "shell/.bash_exports"
    "shell/.bash_functions"
    "shell/.bash_logout"
    "shell/.bash_options"
    "shell/.bash_profile"
    "shell/.bash_prompt"
    "shell/.bashrc"
    "shell/.inputrc"
    "tmux/.tmux.conf"               # tmux
    "vim/.vim"                      # vim
    "vim/.vimrc"
  )

  local i=""
  local src=""
  local tgt=""

  for i in "${FILES[@]}"; do
    src="$(pwd)/src/$i"
    tgt="$HOME/$(printf "%s" "$i" | sed "s/.*\/\(.*\)/\1/g")"

    execute "cp -rf $src $tgt" "$tgt"
  done
}


install_packages() {
  declare -a PACKAGES=(
    "git"
    "curl"
    "vim"
    "tmux"
    "build-essential"
    "shellcheck"
  )

  local i=""

  for i in "${PACKAGES[@]}"; do
    execute "sudo apt install -qqy $i" "$i"
  done
  
  execute "wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash" "nvm"
}


main() {
  print_in_color "          __      __  _____ __            \n" 1
  print_in_color "     ____/ /___  / /_/ __(_) /__  _____   \n" 2
  print_in_color "    / __  / __ \/ __/ /_/ / / _ \/ ___/   \n" 3
  print_in_color "   / /_/ / /_/ / /_/ __/ / /  __(__  )    \n" 5
  print_in_color "   \__,_/\____/\__/_/ /_/_/\___/____/     \n" 6
  printf "\n"

  if [[ "$1" == "" ]]\
    || [[ "$1" == "--full" ]] \
    || [[ "$1" == "--f" ]]; then
    # nothing specific
    print_in_color "\nCopying config...\n" $C_CYAN

    copy_config
  fi

  if [[ "$1" == "--pack" ]] \
    || [[ "$1" == "-p" ]] \
    || [[ "$1" == "--full" ]] \
    || [[ "$1" == "--f" ]]; then

    be_sudo

    # specific install packages
    print_in_color "\nInstalling packages...\n" $C_CYAN

    install_packages
  fi

  printf "\ndotfiles: completed\n"
}

main "$@"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

unset -f print_in_color
unset -f execute
unset -f copy_config
unset -f install_packages
unset -f main
