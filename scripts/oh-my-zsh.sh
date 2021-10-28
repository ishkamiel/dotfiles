#! /usr/bin/env bash
#
# Copyright (C) 2019 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.
#

set -e

INSTALL_DIR="${DOTFILES}/.oh-my-zsh"

if [[ -e "${INSTALL_DIR}" ]]; then
	exit 0;
fi

git clone https://github.com/ohmyzsh/ohmyzsh.git "${INSTALL_DIR}"

echo 'Change default shell to zsh with:'
#shellcheck disable=SC2016
echo '    chsh -s $(which zsh)'

