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

command -v cscope >/dev/null 2>&1 && alias kscope="cscope -R -k -Iarch/x86/include -Iinclude -sarch/x86 -sblock -scerts -scrypto -sdrivers -sfs -sinclude -sinit -sipc -skernel -slib -smm -snet -ssound -svirt"

command -v ag >/dev/null 2>&1 && alias ag="ag --ignore cscope.out"
command -v ag >/dev/null 2>&1 && alias kag="ag --ignore-dir Documentation --ignore-dir tools --ignore-dir scripts"
command -v ag >/dev/null 2>&1 && alias gag="ag --ignore-dir testsuite --ignore-dir doc --ignore 'ChangeLog*'"
