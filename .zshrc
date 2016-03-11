# The .bashrc file is setup to automatically switch over to zsh, unless the NOBASH2ZSH
# variable is set. Setting it here allows bash to be launched without automatically reverting
# back to bash.
export NOBASH2ZSH=1

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.zsh-custom

ZSH_THEME="agnoster"

# Used by the agnoster theme
DEFAULT_USER='ishkamiel'

# Oh-My-Zsh options
CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

# Oh-My-Zsh plugins
plugins=(\
    vi-mode \
    gitignore \
    command-not-found \
    colored-man-pages \
    vundle \
    # custom plugins
    dotbot \
    )

# User configuration
INC_APPEND_HISTORY=

# Check if Oh-My-Zsh is installed, and possible install
if [ ! -e "${ZSH}" ]; then; echo "clone oh-my-zsh?"; read -q answer; if [ "y" -eq "$answer" ]; then
    git clone --depth=1 "https://github.com/robbyrussell/oh-my-zsh.git" "${ZSH}"
fi; fi;

# Load Oh-My-Zsh
[ -e "${ZSH}/oh-my-zsh.sh" ] && source "${ZSH}/oh-my-zsh.sh"

# Additional aliases
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# For "normal" .. .
zstyle ':completion:*' special-dirs true

# Don't share history between zsh instances
unsetopt sharehistory

# Ctrl-R backward search
bindkey '^R' history-incremental-search-backward
