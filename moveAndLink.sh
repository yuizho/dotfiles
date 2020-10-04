#!/bin/sh

mv ~/.bash_profile ~/dotfiles/.bash_profile
mv ~/.bashrc ~/dotfiles/.bashrc
mv ~/.zprofile ~/dotfiles/.zprofile
mv ~/.zshrc ~/dotfiles/.zshrc
mv ~/.emacs.d ~/dotfiles/.emacs.d

ln -s ~/dotfiles/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.zprofile ~/.zprofile
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.emacs.d ~/.emacs.d

