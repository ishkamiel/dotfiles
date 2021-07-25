#! /usr/bin/env bash
#
# Copyright (C) 2019 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.
#

set -e

if [[ -e ~/.oh-my-zsh ]]; then
	exit 0;
fi

git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

echo 'Change default shell to zsh with:'
#shellcheck disable=SC2016
echo '    chsh -s $(which zsh)'

