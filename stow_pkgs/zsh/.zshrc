# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export DEFAULT_USER=ishkamiel
export DOTFILES="${HOME}/.dotfiles"

__prepend_to_PATH() {
  local new_path="$1"
  if [[ -e "$new_path" ]]; then
    # Only add if if it's not already in the PATH
    case ":$PATH:" in; *:$new_path:*) ;; ; *) [ -e "$new_path" ] && export PATH="$new_path:${PATH}" ;; ; esac
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

# If set to true, then more agressivfe features may be loaded
export ISH_ZSH_FULL=$(false)

# Load some local overrides, if they exist
[[ -e "$HOME/.zshrc_local" ]] && source "$HOME/.zshrc_local"

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.dotfiles/external/oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

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
if ! ${ISH_ZSH_FULL}; then
    DISABLE_UNTRACKED_FILES_DIRTY="true"
fi

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM="${HOME}/.dotfiles/oh-my-zsh"

# Workaround for fzf installed on macOS using MacPorts
[[ -e /opt/local/share/fzf ]] && export FZF_BASE=/opt/local/share/fzf
# Override with custom fzf installation, if available
if [[ -e ${DOTFILES}/external/fzf/bin/fzf ]]; then
  export FZF_BASE=${DOTFILES}/external/fzf
  __prepend_to_PATH "${DOTFILES}/external/fzf/bin"
fi

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to "${ZSH_CUSTOM}/plugins"
#
# NOTE: Load order matters! (e.g., fzf breaks list is sorted
#
plugins=(
  docker
  direnv
  rvm
  vi-mode
  command-not-found
  nvim
  fzf
  # golang
  # nvm
  # rust
)

source $ZSH/oh-my-zsh.sh

# Configure fzf
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'eza -n --tree {} | head -n200' ;;
    *)            fzf "$@" ;;
  esac
}

# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'batcat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Print tree structure in the preview window
export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'eza -n --tree {} | head -n200'"

# export FZF_CTRL_T_OPTS="
#   --preview 'test -f {}l && file {} | grep '"':.*text'"' > /dev/null && batcat -n --color=always {} | tail -n200'
#   --bind 'ctrl-/:change-preview-window(down|hidden|)'"

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


# setopt share_history
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS

# Use nvim as vim, if available
command -v nvim >/dev/null 2>&1 && alias vim="nvim"

__prepend_to_PATH "${HOME}/.local/bin"
__prepend_to_PATH "${HOME}/bin"

# Set the pager
export PAGER='less -X -F'

# Use bat, if available (even if installed as batcat)
command -v batcat >/dev/null 2>&1 && alias bat="batcat"
if command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

# Load system vendor-completionns
fpath=($fpath /usr/share/zsh/vendor-completions)
compinit

# Configure Go (golang) stuff
[[ -e "${HOME}/opt/go" ]] && __prepend_to_PATH "${HOME}/opt/go/bin"
export GOPATH="${HOME}/go"

# Configure Rust stuff
__prepend_to_PATH "${HOME}/.cargo/bin"

# Configure Ruby stuff

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
__prepend_to_PATH "${HOME}/.rvm/bin"
[[ -e "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"

# Configure Node.js stuff
# Set up NVM from MacPorts, if installed
if [[ -e "/opt/local/share/nvm/nvm.sh" ]]; then
    # Set up nvm from MacPorts
    [ -z "$NVM_DIR" ] && export NVM_DIR="$HOME/.nvm"
    # "nvm exec" and certain 3rd party scripts expect "nvm.sh" and "nvm-exec" to exist under $NVM_DIR
    [ -e "$NVM_DIR" ] || mkdir -p "$NVM_DIR"
    [ -e "$NVM_DIR/nvm.sh" ] || ln -s /opt/local/share/nvm/nvm.sh "$NVM_DIR/nvm.sh"
    [ -e "$NVM_DIR/nvm-exec" ] || ln -s /opt/local/share/nvm/nvm-exec "$NVM_DIR/nvm-exec"
fi
# Load NVM, if found
if [[ -e "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Configure RISC-V toolchain
export RISCV="${HOME}/opt/riscv"

# Set EDITOR
export EDITOR=vim

# Add dotfiles
__prepend_to_PATH "${HOME}/.dotfiles/bin"

# # Configure Zoxide
# command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"

# Configure OCaml stuff (OCamml Package Manager, opam)
command -v opam >/dev/null 2>&1 && eval "$(opam env)"

# Use eza instead of ls, if available
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --color=always --git"
  alias tree="eza --tree --color=always"
fi

# Ass source highlighting to LESSOPEN, if available
src_highlight_lesspipe="/usr/share/source-highlight/src-hilite-lesspipe.sh"
command -v "${src_highlight_lesspipe}" >/dev/null 2>&1 && export LESSOPEN="| ${src_highlight_lesspipe} %s"

# Use dust instead of du, if available
if command -v dust >/dev/null 2>&1; then
  alias du="dust"
fi
