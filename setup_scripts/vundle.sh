#! /bin/sh
#
# vundleUpdate.sh
# Copyright (C) 2016 ishkamiel <ishkamiel@ultreal>
#
# Distributed under terms of the MIT license.
#

git submodule update --init --recursive "${HOME}/.vim/bundle/Vundle.vim"
vim +PluginInstall +qall
