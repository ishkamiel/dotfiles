#! /usr/bin/env bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#
################################################################
#
# Installs vim-plug for neovim, if we have neovim installed.
#

set -e

# shellcheck source=../lib/downloadFile.sh
. "${DOTFILES}/lib/downloadFile.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

FN_VIM="${HOME}/.vim/autoload/plug.vim"
FN_NEOVIM="${HOME}/.config/nvim/autoload/plug.vim"
URL_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# Install vim-plug for neovim if it's installed
###############################################

if command -v vim >/dev/null 2>&1; then
  echo "=== Found vim, checking and updating config..."
	if [[ ! -e ${FN_VIM} ]]; then
		# If needed, just copy vim-plug into neovim from vim
		mkdir -p "$(dirname "${FN_VIM}")"
		downloadFile "${URL_PLUG}" "${FN_VIM}"
	fi
	d_print "Trying to launch vim to run PlugInstall"
	[[ -e ${FN_VIM} ]] && vim +PlugInstall +qall
fi

if command -v nvim >/dev/null 2>&1; then
  echo "=== Found nvim, checking and updating config..."
	if [[ ! -e ${FN_NEOVIM} ]]; then
		# If needed, just copy vim-plug into neovim from vim
		mkdir -p "$(dirname "${FN_NEOVIM}")"
		downloadFile "${URL_PLUG}" "${FN_NEOVIM}"
		mkdir -p ~/.config/nvim/minisnip
	fi
	d_print "Trying to launch nvim for plugin install"
	[[ -e ${FN_NEOVIM} ]] && nvim +PlugInstall +qall
fi

