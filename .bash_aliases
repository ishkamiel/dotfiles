#!/bin/sh

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# make with -j set to online processor count
alias makej="make -j `getconf _NPROCESSORS_ONLN`"

# Map e to some vim
command -v nvim >/dev/null 2>&1 && alias vim="nvim"
