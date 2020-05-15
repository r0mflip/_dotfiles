#!/usr/bin/env bash

copy_files() {
  src_dir="$1"
  dest="$2"

  echo "=> Copying files"

  declare -a FILES=(
    "bash/bash_aliases"
    "bash/bash_autocomplete"
    "bash/bash_colors"
    "bash/bash_exports"
    "bash/bash_functions"
    "bash/bash_logout"
    "bash/bash_options"
    "bash/bash_profile"
    "bash/bash_prompt"
    "bash/bashrc"
    "bash/inputrc"

    "git/gitattributes"
    "git/gitconfig"
    "git/gitignore"

    "tmux/tmux.conf"

    "vim/vim"
    "vim/vimrc"
  )

  for file in "${FILES[@]}"; do
    sourceFile="$src_dir/$file"
    targetFile="$dest/.$(printf "%s" "$file" | sed "s/.*\/\(.*\)/\1/g")"

    if command cp -rfp $sourceFile $targetFile 2>/dev/null; then
      echo "     $file -> $targetFile"
    else
      echo >&2 "     Failed to copy '$file'"
    fi
  done

  return
}

copy_files $@
