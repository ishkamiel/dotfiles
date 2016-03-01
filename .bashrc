# vim:fdm=marker foldlevel=0
#
# DESCRIPTION
###########################
#
# My bashrc, probably originaly based on the Ubuntu default one, but maybe not, the additional
# notation is for vim folding (. I switched to zsh at some point, so most of the stuff here might
# have fallen quite out of date. Since bash still tends to be the default shell I leave it as is an
# use bash to start either tmux or zsh when available (not that elegant, but won't need system wide
# settings thus working on user-privile-only remote systems, and still concentrates most trickery
# here.
#
# NOTE for vim beginners:
#
#       In short; You can open all folds by typing zR in normal mode, close them with zM, and toggle
#       individual ones with za.For more information you can either use the vim documentation ':h
#       folding', or visit: http://vim.wikia.com/wiki/Folding.
#

# Just stop here if we're not interactive {{{

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
if [ -e /usr/bin/zsh ]; then
    # Switch to zsh if available
    exec /usr/bin/zsh
fi

# }}}

# History settings {{{

# Ignore commands with leading space and duplicates (ignorespace ignoredups)
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=4000

# }}}

# Various options {{{

set -o vi
export EDITOR="/usr/bin/vim"

# set variable identifying the chroot you work in
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# }}}

# Prompt stuff {{{

PROMPT_DIRTRIM=1

# Some settings for the git-prompt thingy
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
# GIT_PS1_DESCRIBE_STYLE="default"
GIT_PS1_SHOWCOLORHINTS=1

# Colors variables {{{

# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White

# }}}

# Set some prompt paths for use in the actuall prompt
Pd_jobs="${Green}(\j)${Color_Off}"
Pd_chroot="${debian_chroot:+($debian_chroot)}"

if [ -n "$SSH_CLIENT" ]; then
    Pd_userNHostColor="${BICyan}"
else
    Pd_userNHostColor="${BGreen}"
fi
Pd_userNhost="${Pd_userNHostColor}\u@\h${Color_Off}"
Pd_cwd="${BBlue}\w${Color_Off}"
Pd_default="${Pd_userNhost}:${Pd_cwd}"
Pd_time="${BCyan}\T${Color_Off}"

if [ -f .git-prompt.sh ]; then
    source .git-prompt.sh
    #PROMPT_COMMAND='__git_ps1 "${Pd_jobs} ${Pd_chroot}${Pd_userNhost}" " ${Pd_cwd} \n \$ "'
    PROMPT_COMMAND='__git_ps1 "${Pd_jobs} ${Pd_chroot}${Pd_userNhost}:${Pd_cwd}" "\$ "'
else
    PS1="${Pd_jobs} ${Pd_chroot}${Pd_userNhost} ${Pd_cwd}\$ "
fi

# }}}

# Aliases {{{

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

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias git-log="git log --pretty=oneline"
alias git-compush='git commit -am \"wip\"; git push'

alias tmux-local="/usr/bin/env TERM=xterm-256color /usr/bin/tmux -2 -u new-session -s local -A -D -P"

# }}}
