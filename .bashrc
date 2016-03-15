case $- in # Stop unless interactive
    *i*) ;;
    *) return;;
esac

if [ -x /usr/bin/tmux ] && [ -z "${TMUX}" ];then
    TMUX_SESSION=''

    # Then change them according to the environment
    if [ -n "$DROPDOWNTERMINAL" ]; then
        # Use a separate tmux session for drop down terminals (Guake, Tilda or similar). This is an
        # environmental variable that is set manually when launching the terminal.
        TMUX_SESSION='dd'
    elif [ -n "$SSH_TTY" ]; then
        # TODO: This currently won't work for ssh sessions, need to look into this!
        TMUX_SESSION='ssh'
    fi

    if [ -n "${TMUX_SESSION}" ]; then
        TERM='screen-256color' exec /usr/bin/tmux new-session -s $TMUX_SESSION -A -D
    fi
fi

set -o vi
export EDITOR="/usr/bin/vim"

DEFAULT_USER=ishkamiel
source ${HOME}/.bash/agnoster
source ${HOME}/.bash/aliases

HISTSIZE=2000
HISTFILESIZE=4000
HISTCONTROL=ignoreboth  # Ignore leading space & duplicates (ignorespace ignoredups)
shopt -s histappend     # append to the history file, don't overwrite it

shopt -s checkwinsize   # update LINES and COLUMNS after commands
shopt -s globstar       # enable ** to match in subdirs

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
