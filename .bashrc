case $- in # Stop unless interactive
	*i*) ;;
	*) return;;
esac

# Try to make sure these are available (mainly affects first run)...
[[ -z "${DOTFILES}" ]] && export DOTFILES="${HOME}/.dotfiles"
[[ -z "${DOTFILES_BASH}" ]] && export DOTFILES_BASH="${DOTFILES}/bash"
[[ -z "${ISHLIB}" ]] && export ISHLIB="${DOTFILES_BASH}/lib/ishlib.sh"

# Load system bash_completion stuff
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

DEBUG=				# Enable debug output
ISHDOT_TMUX_ENABLE=		# Disable all tmux stuff
ISHDOT_TMUX_ALWAYS=		# Always try to enter a tmux session
ISHDOT_TMUX_ON_SSH=		# Enable tmux on ssh ogins

# Override any of these in ~/.bashrc_local
[[ -s "${HOME}/.bashrc_local" ]] && . ${HOME}/.bashrc_local
[[ -s "${ISHLIB}" ]] && . "${ISHLIB}"

# Switch xterm to xterm-256color (needs to be set before launching tmux!)
[[ "${TERM}" = "xterm" ]] && export TERM="xterm-256color"

# Do some horrible (probably no longer working checking before tmux
if [[ ! -n $ISHDOT_TMUX_ENABLE ]]; then
	IshDebugPrint "ISHDOT_TMUX_ENABLE unset"
else
	if [[ ! -x /usr/bin/tmux ]]; then
		IshDebugPrint "Cannot find tmux executable!"
	elif [ -z "${TMUX}" ]; then # Don't nest tmux!
		TMUX_SESSION=;

		if [ -n "${DROPDOWNTERMINAL}" ]; then
			# Set manually when launching guake/tilda to always use same session
			IshDebugPrint "using drop down terminal tmux session"
			TMUX_SESSION='dd'
		elif [ -n "${SSH_TTY}" ]; then
			if [ -n ${ISHDOT_TMUX_ON_SSH} ]; then
				# SSH_TTY is automatically set for ssh sessions
				IshDebugPrint "using ssh tmux session"
				TMUX_SESSION='ssh'
			else
				IshDebugPrint "skipping tmux, ISHDOT_TMUX_ON_SSH unset"
			fi
		elif [ -n "${ISHDOT_TMUX_ALWAYS}" ]; then
			# Try to find a detached session
			IshDebugPrint "trying to find unattached tmux session"
			TMUX_SESSION=$(tmux list-sessions \
				-F '#{session_attached},#{session_name}' |\
				grep ^0 | head -n1 | sed 's/.*,//')
		fi

		if [ -n "${TMUX_SESSION}" ]; then
			IshDebugPrint "attaching to ${TMUX_SESSION} session"
			[[ -n "${DEBUG}" ]] && sleep 3
			exec /usr/bin/tmux -u new-session -s $TMUX_SESSION -A
		elif [ -n "${ISHDOT_TMUX_ALWAYS}" ]; then
			IshDebugPrint "creating new tmux session"
			[[ -n "${DEBUG}" ]] && sleep 3
			exec /usr/bin/tmux -u new-session
		else
			IshDebugPrint "cannot find applicable tmux session"
		fi
	fi
fi

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
	VTE_PROFILE=$(ls /etc/profile.d/vte*)
	if [ $VTE_PROFILE ]; then
		source ${VTE_PROFILE}
		command -v __vte_osc7 >/dev/null 2>&1 && VTE_PWD_THING="$(__vte_osc7)"
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

IshDebugPrint "Setting up RVM if available"
ish_insertPath "${HOME}/.rvm/bin" \
	&& export rvm_silence_path_mismatch_check_flag=1

# Load bash functions
source "${DOTFILES}/bash/functions/gitignore.sh"

# Load NVM
export NVM_DIR="/home/ishkamiel/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Setup ccache, provided CCACHE_DIR is set
IshDebugPrint "Trying to load cache"
if [[ -n "${CCACHE_DIR}" ]]; then
	ccache_path="/usr/lib/ccache"

	if [[ ! -e "${ccache_path}" ]]; then
		$DEBUG && ErrorLog "cannot find ccache binaries"
	else
		# Make sure the ccache dir actually exists
		[[ -e "${CCACHE_DIR}" ]] || mkdir -p "${CCACHE_DIR}"
		# Insert cache into path
		ish_insertPath "/usr/lib/ccache"
		# Sets the path where the "real" non-cache compiler are
		export CCACHE_PATH="/usr/bin"
	fi
fi

export LESS='-R -X -F'
command -v lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"

# Use hostname as windowname when in ssh session
# [[ -n $SSH_CLIENT ]] && printf "\033k`hostname -s`\033\\"

# Load bash aliases
source ${HOME}/.bash_aliases

[[ -s "${ISHLIB}" ]] && CleanIshlib
# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4
