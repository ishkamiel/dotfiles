#!/bin/bash

FILENAME="${HOME}/.config/nvim/autoload/plug.vim"
URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

if command -v nvim >/dev/null 2>&1
then
	if [[ ! -e "${FILENAME}" ]]; then
		echo "Downloading vim-plug"
		curl -fLo "${FILENAME}" --create-dirs "${URL}"
	fi
    nvim +PlugInstall +qall
else
    echo "Cannot find nvim, skipping neovim config"
fi
