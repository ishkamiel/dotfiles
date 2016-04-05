#!/bin/bash

if [[ ! "${DEFAULT_HOSTNAME}" = $(hostname) ]]; then
    DST="${HOME}/.vimrc"
    SRC="${DOTFILES}/.vimrc_lite"

    # Exit unless a lite version exists
    [[ -e $SRC ]] || exit

    # Exit unless dest safe to remove
    [[ -e $DST ]] && [[ ! -h $DST ]] && exit

    [[ -e $DST ]] && rm $DST
    ln -s $SRC $DST
fi

FILENAME="${HOME}/.vim/autoload/plug.vim"
URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

if [[ ! -e "${FILENAME}" ]]; then
    echo "Downloading vim-plug"
    [[ -e "${FILENAME}" ]] || curl -fLo "${FILENAME}" --create-dirs "${URL}"
fi
vim +PlugInstall +qall

