#!/usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

set -euo pipefail

INSTALL_DIR="${DOTFILES}/external/oh-my-zsh"

if [[ -e "${INSTALL_DIR}/.git" ]]; then
  echo "=== oh-my-zsh found in ${INSTALL_DIR}"
	exit 0;
fi

echo "=== Installing oh-my-zsh to ${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
git clone https://github.com/ohmyzsh/ohmyzsh.git "${INSTALL_DIR}"

echo 'Change default shell to zsh with:'
#shellcheck disable=SC2016
echo '    chsh -s $(which zsh)'
