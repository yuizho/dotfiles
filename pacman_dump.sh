#!/usr/bin/env bash

set -ue

current_dir=$(dirname "${BASH_SOURCE[0]:-$0}")
datetime=$(date +%Y%m%d%H%M%S)

echo "=====> start creating pacman package backup"
tar -cjf "${current_dir}/.pacman_backup/${datetime}-pacman-database.tar.bz2" "/var/lib/pacman/local"
echo "Done!"


echo "=====> start dumping abs, aur packages"
pacman -Qqne > "${current_dir}/.abs_packages"
echo "dumped abs packages to ${current_dir}/.abs_packages"
pacman -Qqme > "${current_dir}/.aur_packages"
echo "dumped aur packages to ${current_dir}/.aur_packages"
