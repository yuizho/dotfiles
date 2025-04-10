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

if [ ! -e /opt/homebrew/bin/brew ]; then
    echo "=====> Homebrew is not installed!"
    echo "=====> please install Homebrew"
    echo "=====> https://brew.sh/"
    exit 1
fi

echo "=====> start package instllation"
dotfiles_dir="$1"
/opt/homebrew/bin/brew bundle install --file "${dotfiles_dir}/mac/.Brewfile"

echo "=====> configure PATH for commands installed by brew!!"
export PATH="/opt/homebrew/bin:$PATH"

if ! command -v sdk &> /dev/null; then
    echo "=====> SDKMAN is not installed!"
    echo "=====> start installing SDKMAN"
    curl -s "https://get.sdkman.io" | bash
fi

echo "=====> package instllation is complete!!"
