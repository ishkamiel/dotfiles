case $- in # Stop unless interactive
    *i*) ;;
    *) return;;
esac

# Load the system default bashrc
[ -e /etc/bash.bashrc ] && source /etc/bash.bashrc

# This will possibly load tmux, just uncomment to disable
source "${HOME}/.bash/tmux"

set -o vi
export EDITOR="/usr/bin/vim"

DEFAULT_USER=ishkamiel
source ${HOME}/.bash/agnomod.theme
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

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
