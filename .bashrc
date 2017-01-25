case $- in # Stop unless interactive
    *i*) ;;
    *) return;;
esac

# Load system bash_completion stuff
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# Switch xterm to xterm-256color (needs to be set before launching tmux!)
[ "$TERM" = "xterm" ] && export TERM="xterm-256color"

# Check if we've got tmux available
if [ -x /usr/bin/tmux ] && [ -z "${TMUX}" ];then
	# Start tmux if DROPDOWNTERMINAL or SSH_TTY set
	# 	DROPDOWNTERMINAL is manually set when I launch guake
	#	SSH_TTY is automatically set for ssh sessions
    TMUX_SESSION=
    [[ -n "${DROPDOWNTERMINAL}" ]] && TMUX_SESSION='dd'
    [[ -n "${SSH_TTY}" ]] && TMUX_SESSION='ssh'
	if [ -n "${TMUX_SESSION}" ]; then
        #exec /usr/bin/tmux new-session -s $TMUX_SESSION -A -D
        exec /usr/bin/tmux new-session -s $TMUX_SESSION -A
	fi
fi

# Load the agnoster/powerline prompt theme
source "${DOTFILES_BASH}/agnomod.theme"

# Git prompt settings (used by the modified agnoster theme)
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=true

# History stuff
HISTSIZE=5000           # Bash command line history size
HISTFILESIZE=100000
HISTCONTROL=ignoreboth  # Ignore leading space & duplicates (ignorespace ignoredups)
shopt -s histappend     # append to the history file, don't overwrite it
# After each command, append to the history file and reread it
# PROMPT_COMMAND_HIST="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
if [[ -z "${PROMPT_COMMAND}" ]]; then
	export PROMPT_COMMAND="${PROMPT_COMMAND_HIST}"
else
	export PROMPT_COMMAND="${PROMPT_COMMAND}; ${PROMPT_COMMAND_HIST}"
fi

shopt -s checkwinsize   # update LINES and COLUMNS after commands
shopt -s globstar       # enable ** to match in subdirs

set -o vi               # enable Bash Vim mode
set -o ignoreeof        # ignore ctrl-D

# Set vim to default editor
export EDITOR="/usr/bin/vim"
command -v nvim >/dev/null 2>&1 && export EDITOR="$(which nvim)"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# Load bash aliases
source ${HOME}/.bash_aliases

# Load bash functions
source "${DOTFILES}/bash/functions/gitignore.sh"

# Load local bashrc
source ${HOME}/.bashrc_local

export NVM_DIR="/home/ishkamiel/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Setup ccache, provided CCACHE_DIR is set
if [ -n "${CCACHE_DIR}" ]; then
	export PATH="/usr/lib/ccache:$PATH"
	export CCACHE_PATH="/usr/bin"
	# Need to make make+ccache use color output
	export MAKEFLAGS="CFLAGS=-fdiagnostics-color=always"
	[ -e "${CCACHE_DIR}" ] || mkdir -p "${CCACHE_DIR}"
fi
