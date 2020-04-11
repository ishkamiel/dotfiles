# ------------------------------------------------------------------------------
#          FILE:  nvim.plugin.zsh
#   DESCRIPTION:  oh-my-zsh plugin file.
#        AUTHOR:  Sorin Ionescu (sorin.ionescu@gmail.com)
#       VERSION:  1.0.0
# ------------------------------------------------------------------------------


if (( ${+commands[nvim]} )); then
  export EDITOR='nvim'
elif (( ${+commands[vim]} )); then
  export EDITOR='vim'
elif (( ${+commands[vi]} )); then
  export EDITOR='vi'
fi
