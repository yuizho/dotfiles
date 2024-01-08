#!/usr/bin/env bash

set -ue

if [ "$#" -lt 2 ]; then
    echo "${BASH_SOURCE[0]:-$0} needs 2 parameters" 1>&2
    exit 1
fi


ln_option="$1"
dotfiles_dir="$2"
dotfiles_abs_dir=$(realpath $dotfiles_dir)

echo "=====> start extra configurations for linux"

echo "=====> configurations for x"
ln $ln_option "${dotfiles_abs_dir}/linux/x/.xprofile" ~/
sudo cp "${dotfiles_dir}/linux/x/00-keyboard.conf" /etc/X11/xorg.conf.d/
sudo cp "${dotfiles_dir}/linux/x/30-touchpad.conf" /etc/X11/xorg.conf.d/

echo "=====> extra configurations for linux is complete!!"
