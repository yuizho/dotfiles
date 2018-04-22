#!/bin/sh

mv ~/.bash_profile ~/dotfiles/.bash_profile
mv ~/.bashrc ~/dotfiles/.bashrc
mv ~/.emacs.d ~/dotfiles/.emacs.d

ln -s ~/dotfiles/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.emacs.d ~/.emacs.d

