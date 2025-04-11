#!/usr/bin/env bash

set -ue

if [ "$#" -eq 0 ]; then
    echo "no arguments supplied to ${BASH_SOURCE[0]:-$0}" 1>&2
    exit 1
fi


dotfiles_dir="$1"

echo "=====> start extra configurations for mac"

# python
py_version=$(/opt/homebrew/bin/brew list | grep -E '^python@.+' | sed 's/python@//' | sort -n | head -n 1)
echo "=====> create symlink for python${py_version} in mac"
sudo ln -sf "/opt/homebrew/bin/python${py_version}" "/usr/local/bin/python"

# iterm
echo "=====> About configuration for iterm"
echo "You needs to set iterm config file path (${dotfiles_dir}/mac/iterm/com.googlecode.iterm2.plist)"
echo "from iterm preference 'General > Preferences > Load preferences from a custom folder or URL'."
echo "After the opelation you need to reboot OS to apply the configurations."

# yabai & skhd
echo "=====> Start yabai & skhd"
# https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)
yabai --start-service
# https://github.com/koekeishiya/skhd?tab=readme-ov-file#install
skhd --start-service

# karabiner
echo "=====> Restart karabiner to load karabiner configs"
echo "=====> https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/"
launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server

echo "=====> extra configurations for mac is complete!!"
