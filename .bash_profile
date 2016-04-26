[[ -s "${HOME}/.profile" ]] && . "${HOME}/.profile"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

true # Make sure $?=0, that is that the last command returned with 0 (=success).
