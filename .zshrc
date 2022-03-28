# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export DEFAULT_USER=ishkamiel

# Load some local overrides, if they exist
[[ -e "$HOME/.zshrc_local" ]] && source "$HOME/.zshrc_local"

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.dotfiles/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="powerlevel10k/powerlevel10k"

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
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="${HOME}/.dotfiles/oh-my-zsh"

# Workaround for fzf installed on macOS using MacPorts
[[ -e /opt/local/share/fzf ]] && export FZF_BASE=/opt/local/share/fzf

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to "${ZSH_CUSTOM}/plugins"
plugins=(
  docker
  golang
  nvm
  rvm
  vi-mode
  command-not-found
  nvim
  fzf
)

source $ZSH/oh-my-zsh.sh

# User configuration

#alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color"
alias git-dc="git diff --color-words --color"
alias cp="cp -i"
alias rm="rm -i"
alias mv="mv -i"

setopt HIST_IGNORE_SPACE
unsetopt share_history

command -v nvim >/dev/null 2>&1 && alias vim="nvim"

[[ ":$PATH:" != *":$HOME/.local/bin:"* && -e "${HOME}/.local/bin" ]] && \
    export PATH="${HOME}/.local/bin:${PATH}"
[[ ":$PATH:" != *":$HOME/bin:"* && -e "${HOME}/bin" ]] && \
    export PATH="${HOME}/bin:${PATH}"
export PAGER='less -X -F'

export GOPATH="${HOME}/go"

# Make sure we load system vendor-completionns
fpath=($fpath /usr/share/zsh/vendor-completions)
compinit


[[ ":$PATH:" != *":$HOME/.cargo/bin:"* && -e "${HOME}/.cargo/bin" ]] && \
    export PATH="$HOME/.cargo/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
[[ ":$PATH:" != *":$HOME/.rvm/bin:"* && -e "${HOME}/.rvm/bin" ]] && \
    export PATH="${HOME}/.rvm/bin:${PATH}"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# RISC-V toolchain and stuff here
export RISCV="${HOME}/opt/riscv"

alias whatsmyip="dig +short myip.opendns.com @resolver1.opendns.com"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
