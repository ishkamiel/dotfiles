#!/usr/bin/env bash

if [[ -e "${DOTFILES}/lib/downloadFile.sh" ]]; then
	source "${DOTFILES}/lib/downloadFile.sh"
else
	exit 1;
fi
[[ -z "${LIB_DEBUG_SH}" ]] && source "${DOTFILES}/lib/debug.sh"

FN_VIM="${HOME}/.vim/autoload/plug.vim"
FN_NEOVIM="${HOME}/.config/nvim/autoload/plug.vim"
URL_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# Install vim-plug for vim
##########################

# if [[ -e "${FN_VIM}" ]]; then
# 	if [[ ! -f "${FN_VIM}" ]]; then
# 		echo "Found ${FN_VIM}, but it's not a file!"
# 		exit 1;
# 	fi
# else
# 	mkdir -p "$(dirname ${FN_VIM})"
# 	downloadFile "${URL_PLUG}" "${FN_VIM}"
# fi
# d_print "Trying to launch vim for plugin install"
# [[ -e ${FN_VIM} ]] && vim +PlugInstall +qall

# Install vim-plug for neovim IF it's installed
###############################################

if command -v nvim >/dev/null 2>&1
then
	if [[ ! -e ${FN_NEOVIM} ]]; then
		# If needed, just copy vim-plug into neovim from vim
		mkdir -p $(dirname ${FN_NEOVIM})
		downloadFile "${URL_PLUG}" "${FN_NEOVIM}"
		mkdir -p ~/.config/nvim/minisnip
	fi
	d_print "Trying to launch nvim for plugin install"
	[[ -e ${FN_NEOVIM} ]] && nvim +PlugInstall +qall
fi
