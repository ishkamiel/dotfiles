#! /bin/sh

if command -v vim >/dev/null 2>&1 && alias e="vim"
then
    git submodule update --init --recursive "${HOME}/.vim/bundle/Vundle.vim"
    vim +PluginInstall +qall
else
    echo "Cannot find vim, skipping vim config"
fi
