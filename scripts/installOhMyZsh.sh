#!/bin/sh

OHMYZSH_DIR=~/.oh-my-zsh

if ! [ -e $OHMYZSH_DIR ]; then
    echo "Installing oh-my-zsh"
    git clone git://github.com/robbyrussell/oh-my-zsh.git $OHMYZSH_DIR
fi
