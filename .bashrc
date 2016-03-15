# vim:fdm=marker foldlevel=0

# Stop unless interactive
case $- in
    *i*) ;;
    *) return;;
esac

# }}}

# Switch to zsh or tmux if possible {{{

# This is where the aforementioned trickery happens, although in truth this simply looks for tmux,
# or zsh, then does some minor environmental setup, and finally switches to either of those.
#

TMUX_BIN=/usr/bin/tmux
ZSH_BIN=/usr/bin/zsh

# First check tmux & zsh availability, then ensure we're not already inside tmux.
# (My tmux settings run zsh, so tmux will simply exit if it isn't available)
if [ -x $ZSH_BIN ] && [ -x $TMUX_BIN ] && [ ! -n "$TMUX_SESSION" ];then
    # Disable by default, only enable on specific settings. Leaving this here, for possible tweakage
    # later. For now thogh, there is mostly nothing here.
    TMUX_SESSION=''
    TMUX_TERM='screen-256color'

    # Then change them according to the environment
    if [ -n "$DROPDOWNTERMINAL" ]; then
        # Use a separate tmux session for drop down terminals (Guake, Tilda or similar). This is an
        # environmental variable that is set manually when launching the terminal.
        TMUX_SESSION=''
    elif [ -n "$SSH_TTY" ]; then
        # TODO: This currently won't work for ssh sessions, need to look into this!
        TMUX_SESSION='ssh'
    elif [ $TERM = "linux" ]; then
        # Don't run tmux on command line only logins.
        TMUX_SESSION=''
    fi

    # Switch to tmux unless we've unset the TMUX_SESSION to indicate no-tmux.
    if [ -n "$TMUX_SESSION" ]; then
        export TERM="$TMUX_TERM"
        exec /usr/bin/tmux new-session -s $TMUX_SESSION -A -D
    fi
fi

# If we're still here, let's just try to switch to zsh.
if [ ! -n "${ZSH}" ] && [ -e /usr/bin/zsh ]; then
    # Switch to zsh if available
    exec /usr/bin/zsh
fi

# }}}

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
