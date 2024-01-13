#!/usr/bin/env bash
set -ue


if [ "$#" -eq 0 ]; then
    echo "no arguments supplied to ${BASH_SOURCE[0]:-$0}" 1>&2
    exit 1
fi

if [[ ! "$OSTYPE" =~ ^linux* ]]; then
    echo "unexpected OS ($OSTYPE) to install packages for linux" 1>&2
    exit 1
fi

if ! command -v pacman &> /dev/null; then
    echo "unexpected linux distro.this script depends on Pacman."
    echo "see https://en.wikipedia.org/wiki/Category:Pacman-based_Linux_distributions"
    exit 1
fi

echo "=====> start package instllation"
dotfiles_dir="$1"

echo "=====> start abs package instllation by pacman"
cat "${dotfiles_dir}/linux/.abs_packages" | xargs pacman -S --noconfirm

echo "=====> start aur package instllation by yay"
echo "=====> start installing yay"
git clone https://aur.archlinux.org/yay.git "${dotfiles_dir}/yay"
cd "${dotfiles_dir}/yay"
makepkg -si
cd "${dotfiles_dir}"
rm -rf "${dotfiles_dir}/yay"
yay --version

echo "=====> start aur package instllation by yay"
cat "${dotfiles_dir}/linux/.aur_packages" | xargs yay -S --noconfirm

echo "=====> package instllation is complete!!"
