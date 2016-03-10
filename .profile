# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export EDITOR=/usr/bin/vim

TMP_DIR=$HOME/tmp

# AddToPath PATH_TO_ADD [VERBOSE]
# Simple function to add paths without including directories or missing paths
AddToPath() {
    VERBOSE=
    if [ -n "${2}" ]; then VERBOSE=1; fi;

    # Catch typos and bad additions
    if [ ! -e "${1}" ] || [ ! -d "${1}" ]; then
        if [ -n "$VERBOSE" ]; then echo "Trying to add non-existing path ${1}!"; fi
        return 0
    fi

    if [[ "$PATH" =~ (^|:)"${1}"(:|$) ]]; then
        if [ -n "$VERBOSE" ]; then echo "Already in path ${1}, skipping"; fi
        return 0
    fi

    export PATH="$PATH:${1}"
}

STARTUP_DIR="$HOME/.dotfiles/startup"
StartupScript() {
    [ -s "${STARTUP_DIR}/${1}" ] && . "${STARTUP_DIR}/${1}"
}


# export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"


StartupScript "heroku.sh"
StartupScript "nvm.sh"
StartupScript "ruby.sh"
# StartupScript "profile.spark_env.sh""

# set PATH so it includes user's private bin if it exists
if [ -e "$HOME/personal/bin" ]; then AddToPath "$HOME/personal/bin"; fi
if [ -e "$HOME/bin" ]; then AddToPath "$HOME/bin"; fi
AddToPath "$HOME/.local/bin"

# Make sure we have a tempdirectory that we own
if [ ! -e $TMP_DIR ] || [ ! -O $TMP_DIR ]; then
    if [ -L $TMP_DIR ]; then
        rm $TMP_DIR
    fi
    ln -s $(mktemp -d) $TMP_DIR
    setfacl -d -m g::- $TMP_DIR/.
    setfacl -d -m o::- $TMP_DIR/.
    mkdir $TMP_DIR/vimbackup
fi

# Powerline
# if [ -n "$(which powerline-daemon)" ]; then
#     powerline-daemon -q
# fi


############################################################################################
# Any required stuff should be but above this, the next steps could result in launchiing
# other processes, skipping files, or sourcing all sorts of stuff.

BIN_BYOBU_BACKEND=/usr/bin/byobu-tmux
BIN_ZSH=/usr/bin/zsh

if [ -e "$HOME/.profile_local" ];then
    . $HOME/.profile_local
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

