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

command -v nvim >/dev/null 2>&1 && alias vim="nvim"
command -v exa >/dev/null 2>&1 && alias ls="exa --time-style=iso"
command -v cscope >/dev/null 2>&1 && alias kscope="cscope -R -k -Iarch/x86/include -Iinclude -sarch/x86 -sblock -scerts -scrypto -sdrivers -sfs -sinclude -sinit -sipc -skernel -slib -smm -snet -ssound -svirt"

if command -v ag >/dev/null 2>&1; then
	alias ag="ag --ignore cscope.out"
	alias kag="ag --ignore-dir Documentation --ignore-dir tools --ignore-dir scripts"
	alias gag="ag --ignore-dir testsuite --ignore-dir doc --ignore 'ChangeLog*'"
fi

if command -v git >/dev/null 2>&1; then
	alias gdiff="git diff --color-words"
fi
