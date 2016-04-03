case $- in # Stop unless interactive
    *i*) ;;
    *) return;;
esac

# Load the system default bashrc
[ -e /etc/bash.bashrc ] && source /etc/bash.bashrc

# This will possibly load tmux, just uncomment to disable
source "${HOME}/.bash/tmux"

# Load the agnoster/powerline theme
source ${HOME}/.bash/agnomod.theme

# Load bash aliases
source ${HOME}/.bash/aliases

# Git prompt settings (used by the modified agnoster theme)
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=true


HISTSIZE=5000           # Bash command line history size
HISTFILESIZE=10000
HISTCONTROL=ignoreboth  # Ignore leading space & duplicates (ignorespace ignoredups)
shopt -s histappend     # append to the history file, don't overwrite it
shopt -s checkwinsize   # update LINES and COLUMNS after commands
shopt -s globstar       # enable ** to match in subdirs


set -o vi               # enable Bash Vim mode
set -o ignoreeof        # ignore ctrl-D

# Set vim to default editor
export EDITOR="/usr/bin/vim"

# Switch xterm to xterm-256color
[ "$TERM" = "xterm" ] && export TERM="xterm-256color"

# Needs to be loaded here
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
