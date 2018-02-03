# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4
# ~/.profile: executed by the command interpreter for login shells (and desktop :) )

export EDITOR=/usr/bin/vim
export DOTFILES="${HOME}/.dotfiles"
export DOTFILES_BASH="${DOTFILES}/bash"
export TMPDIR="${HOME}/tmp"
export VIMBACKUP="${TMPDIR}/vimbackup"
export ISHLIB="${DOTFILES}/bash/lib/ishlib.sh"

[ -z "${LIB_ISHLIB_SH}" ] && [[ -s "${ISHLIB}" ]] && . "${ISHLIB}"

# Make sure these directories exist
InitTempDir ${TMPDIR}
mkdir -p "${VIMBACKUP}"

# NVM (Node version manager)
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

# RVM
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add some paths
ish_insertPath "${HOME}/.dotfiles/bin"
ish_insertPath "${HOME}/personal/bin"
ish_insertPath "${HOME}/bin"

# Mail env
export MAIL=/var/spool/mail/${USER}

# source ~/.profile_local (See example .profile_local for some variables that stuff in these scripts)
ish_sourceFile "${HOME}/.profile_local"

export PERL5LIB="${HOME}/perl5/lib/perl5"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

[[ -s "${ISHLIB}" ]] && CleanIshlib

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
