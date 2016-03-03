# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.zsh-custom

export NOBASH2ZSH=1
export DOTFILES_HOME="$HOME/.dotfiles"
export DOTFILES_CONFIG="$HOME/.dotfiles/config.yaml"

ZSH_URL="https://github.com/robbyrussell/oh-my-zsh.git"
B_ENV=/usr/bin/env
B_GIT=/usr/bin/git

DEFAULT_USER='ishkamiel'
ZSH_THEME="agnoster"

# Oh-My-Zsh options
CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
# ZSH_CUSTOM=/path/to/new-custom-folder
plugins=(vi-mode gitignore)

# User configuration
INC_APPEND_HISTORY=


# Install oh-my-zsh if not found
if ! [ -e $ZSH ]; then
    echo "oh-my-zsh not found, clone?"
    read -q answer
    if [ "y" -eq "$answer" ]; then
        echo "Okay, trying to clone into $ZSH"

        # Clone!
        $B_ENV $B_GIT clone --depth=1 $ZSH_URL $ZSH

        # Just change over to a new instance
        echo "Ready to start zsh!"
        #exec /usr/bin/zsh
    fi
fi

if [ -e "$ZSH/oh-my-zsh.sh" ]; then
    source $ZSH/oh-my-zsh.sh
fi

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

zstyle ':completion:*' special-dirs false
unsetopt sharehistory

bindkey '^R' history-incremental-search-backward



# ##########################################
# Some global functions for this and that...
# ##########################################
dotfilesUpdate() {
    DOTBOT_BIN="${DOTFILES_HOME}/dotbot/bin/dotbot"

    if [ ! -e $DOTFILES_CONFIG ]; then
        echo "Cannot find dotfiles config: $DOTFILES_CONFIG"; return
    fi

    if [ ! -e $DOTBOT_BIN ]; then
        echo "Cannot find dotbot: $DOTBOT_BIN"; return;
    fi

    # git submodule update --init --recursive "${DIR}"
    $DOTBOT_BIN -d ${DOTFILES_HOME} -c ${DOTFILES_CONFIG}
}

