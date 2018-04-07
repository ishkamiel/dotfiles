# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4

export DOTFILES=${HOME}/.dotfiles

. ${DOTFILES}/lib/functions.bash/pathmunge.sh

_pathmunge "${HOME}/bin"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

# Load Ingel SGX SDK environment
[[ -e /opt/intel/sgxsdk/environment ]] && . /opt/intel/sgxsdk/environment

unset -f _pathmunge
