#!/usr/bin/env bash
set -ue


if [ "$#" -eq 0 ]; then
    echo "no arguments supplied to ${BASH_SOURCE[0]:-$0}" 1>&2
    exit 1
fi

if [[ ! "$OSTYPE" =~ ^darwin* ]]; then
    echo "unexpected OS ($OSTYPE) to install packages for mac" 1>&2
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "=====> Homebrew is not installed!"
    echo "=====> start installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "=====> start package instllation"

dotfiles_dir="$1"
brew bundle install --file "${dotfiles_dir}/.Brewfile"

echo "=====> package instllation is complete!!"
