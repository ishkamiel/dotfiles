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

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(vi-mode gitignore)

# User configuration
INC_APPEND_HISTORY=

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


# Install oh-my-zsh if not found
if ! [ -e $ZSH ]; then
    echo "oh-my-zsh not found, clone?"
    read -q answer
    if [ -n "$answer" ] && [ "y" = $answer ]; then
        echo "Okay, trying to clone into $ZSH"

        # Clone!
        $B_ENV $B_GIT clone --depth=1 $ZSH_URL $ZSH

        # Just change over to a new instance
        echo "Ready to start zsh!"
        #exec /usr/bin/zsh
    fi
fi

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

zstyle ':completion:*' special-dirs true

# Check if we should run a tmux session?
if [ -n "$DROPDOWNTERMINAL" ]; then
    # I manually set this when running Guake, Tilda, or similar
    TMUX_SESSION='dd'
elif [ -n "$SSH_TTY" ]; then
    echo "Byoubu stil managing SSH stuff"
    # TMUX_SESSION='ssh'
elif [[ -o interactive ]]; then
    TMUX_SESSION='def'
fi
# Let byobu handle ssh stuff

# Load tmux if TMUX_SESSION is set
if [ -n "$TMUX_SESSION" ]; then
    # Don't do that if already running tmux!
    export TERM=screen-256color
    if [ ! -n "$TMUX" ] && [ -x /usr/bin/tmux ]; then
        exec /usr/bin/tmux new-session -s $TMUX_SESSION -A -D
    fi
fi
