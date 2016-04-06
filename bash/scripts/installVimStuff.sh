#!/usr/bin/env bash

source "${DOTFILES_BASH}/lib/downloadFile.sh"

FN_VIM="${HOME}/.vim/autoload/plug.vim"
FN_NEOVIM="${HOME}/.config/nvim/autoload/plug.vim"
URL_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# Install vim-plug for vim
##########################

if [[ ! -e "${FN_VIM}" ]]; then
	echo "Downloading vim-plug"
	downloadFile "${FN_VIM}" "${URL_PLUG}"
fi
vim +PlugInstall +qall

# Install vim-plug for neovim IF it's installed
###############################################

if command -v nvim >/dev/null 2>&1
then
	if [[ ! -e "${FN_NEOVIM}" ]]; then
		echo "Downloading vim-plug"
		downloadFile "${FN_NEOVIM}" "${URL_PLUG}"
	fi
    nvim +PlugInstall +qall
else
    echo "Cannot find nvim, skipping neovim config"
fi
