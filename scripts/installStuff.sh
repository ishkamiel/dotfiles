#!/bin/sh

VUNDLE_DIR=~/.vim/bundle/Vundle.vim
OHMYZSH_DIR=~/.oh-my-zsh

if ! [ -e $VUNDLE_DIR ]; then
    echo "Installing Vundle for vim"
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_DIR
fi

if ! [ -e $OHMYZSH_DIR ]; then
    echo "Installing oh-my-zsh"
    git clone git://github.com/robbyrussell/oh-my-zsh.git $OHMYZSH_DIR
fi
