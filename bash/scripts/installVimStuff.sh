#!/usr/bin/env bash

source "${DOTFILES_BASH}/lib/downloadFile.sh"

FN_VIM="${HOME}/.vim/autoload/plug.vim"
FN_NEOVIM="${HOME}/.config/nvim/autoload/plug.vim"
URL_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

# Install vim-plug for vim
##########################

if [[ ! -e "${FN_VIM}" ]]; then
    mkdir -p ${FN_VIM}
	downloadFile "${URL_PLUG}" "${FN_VIM}"
fi
echo "Trying to launch vim for plugin install"
[[ -e ${FN_VIM} ]] && vim +PlugInstall +qall

# Install vim-plug for neovim IF it's installed
###############################################

if command -v nvim >/dev/null 2>&1
then
	if [[ ! -e ${FN_NEOVIM} ]] && [[ -e ${FN_VIM} ]]; then
		# If needed, just copy vim-plug into neovim from vim
        mkdir -p $(dirname ${FN_NEOVIM})
		cp ${FN_VIM} ${FN_NEOVIM}
	fi
    echo "Trying to launch nvim for plugin install"
    [[ -e ${FN_NEOVIM} ]] && nvim +PlugInstall +qall
fi
