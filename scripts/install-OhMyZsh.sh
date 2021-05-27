#! /usr/bin/env bash
#
# Copyright (C) 2019 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.
#

set -e

test -e ~/.oh-my-zsh

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

echo 'Change default shell to zsh with:'
#shellcheck disable=SC2016
echo '    chsh -s $(which zsh)'

