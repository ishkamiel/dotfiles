# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export DEFAULT_USER=ishkamiel
export DOTFILES="${HOME}/.dotfiles"

__prepend_to_PATH() {
  local new_path="$1"
  if [[ -d "$new_path" ]]; then
    # Remove new_path from PATH if it already exists
    PATH=$(echo "$PATH" | sed -e "s;:$new_path;;" -e "s;$new_path:;;" -e "s;$new_path;;")
    # Prepend new_path to PATH
    export PATH="$new_path:$PATH"
  fi
  return 0
}

__get_nproc() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu
  fi
}

# ZSH
export HISTFILE="$HOME"/.zhistory
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt CORRECT
setopt CORRECT_ALL
HISTSIZE=10000
SAVEHIST=10000

autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Load some local overrides, if they exist
[[ -e "$HOME/.zshrc_local" ]] && source "$HOME/.zshrc_local"

# Homebrew for MacOS
__prepend_to_PATH "/opt/homebrew/bin"

# pyenv
export PYENV_ROOT="${HOME}/.pyenv"
__prepend_to_PATH "${PYENV_ROOT}/bin"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# fzf
if [[ -e ${DOTFILES}/external/fzf/bin/fzf ]]; then
  export FZF_BASE=${DOTFILES}/external/fzf
  __prepend_to_PATH "${DOTFILES}/external/fzf/bin"
elif [[ -e /opt/local/share/fzf ]]; then
  export FZF_BASE=/opt/local/share/fzf
fi
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
export HIST_STAMPS="yyyy-mm-dd"

export EDITOR=vim
export PAGER='less -X -F'

__prepend_to_PATH "${HOME}/.dotfiles/bin"
__prepend_to_PATH "${HOME}/.local/bin"
__prepend_to_PATH "${HOME}/bin"

# Aliases
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color"
alias git-dc="git diff --color-words --color"
alias cp="cp -i"
alias rm="rm -i"
alias mv="mv -i"
alias makej="make -j$(__get_nproc)"
alias umakej="unbuffer make -j$(__get_nproc)"
alias whatsmyip="dig +short myip.opendns.com @resolver1.opendns.com"
command -v pytest >/dev/null 2>&1 && alias pytestj="pytest -d -n$(__get_nproc)"

# Use nvim as vim, if available
command -v nvim >/dev/null 2>&1 && alias vim="nvim"

# bat
command -v batcat >/dev/null 2>&1 && alias bat="batcat -p"
command -v bat >/dev/null 2>&1 && alias cat='bat -p'

# Load system vendor-completionns
fpath=($fpath /usr/share/zsh/vendor-completions)
compinit

# Configure Go (golang) stuff
__prepend_to_PATH "${HOME}/opt/go/bin"
__prepend_to_PATH "${HOME}/go/bin"
export GOPATH="${HOME}/go"

# Configure Rust stuff
__prepend_to_PATH "${HOME}/.cargo/bin"

# rvm
__prepend_to_PATH "${HOME}/.rvm/bin"
[[ -e "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"

# Node.js
if [[ -e "/opt/local/share/nvm/nvm.sh" ]]; then
    # Set up nvm from MacPorts
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    # "nvm exec" and certain 3rd party scripts expect "nvm.sh" and "nvm-exec" to exist under $NVM_DIR
    [ -e "$NVM_DIR" ] || mkdir -p "$NVM_DIR"
    [ -e "$NVM_DIR/nvm.sh" ] || ln -s /opt/local/share/nvm/nvm.sh "$NVM_DIR/nvm.sh"
    [ -e "$NVM_DIR/nvm-exec" ] || ln -s /opt/local/share/nvm/nvm-exec "$NVM_DIR/nvm-exec"
fi
export NVM_DIR="$HOME/.nvm"
# Load NVM, if found
if [[ -e "$HOME/.nvm" ]]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# RISC-V toolchain
export RISCV="${HOME}/opt/riscv"

# Configure OCaml stuff (OCamml Package Manager, opam)
command -v opam >/dev/null 2>&1 && eval "$(opam env)"

# Use eza instead of ls, if available
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --color=always"
  alias tree="eza --tree --color=always"
  alias ll="eza --color=always -lh --git --git-repos"
fi

# Ass source highlighting to LESSOPEN, if available
src_highlight_lesspipe="/usr/share/source-highlight/src-hilite-lesspipe.sh"
command -v "${src_highlight_lesspipe}" >/dev/null 2>&1 && export LESSOPEN="| ${src_highlight_lesspipe} %s"

# Use dust instead of du, if available
command -v dust >/dev/null 2>&1 && alias du="dust"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/ishkamiel/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ishkamiel/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ishkamiel/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ishkamiel/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export ROTZ_INSTALL="/home/ishkamiel/.rotz"
__prepend_to_PATH "$ROTZ_INSTALL/bin"
command -v rotz >/dev/null 2>&1 && eval "$(rotz completions)"

eval "$(starship init zsh)"
