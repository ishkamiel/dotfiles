# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4
# ~/.profile: executed by the command interpreter for login shells (and desktop :) )

export EDITOR=/usr/bin/vim
export DOTFILES="${HOME}/.dotfiles"
export DOTFILES_BASH="${DOTFILES}/bash"
export TMPDIR="${HOME}/tmp"
export LOGDIR="${TMPDIR}/log"
export VIMBACKUP="${TMPDIR}/vimbackup"
export ISHLIB="${DOTFILES}/bash/lib/ishlib.sh"

[[ -s "${ISHLIB}" ]] && . "${ISHLIB}"

# Make sure these directories exist
InitTempDir ${TMPDIR}
mkdir -p "${VIMBACKUP}"
mkdir -p "${LOGDIR}"

# Initialize separate error log for .profile
InitErrorLog "${LOGDIR}/profile_errors"

# NVM (Node version manager)
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

# RVM
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add some paths
AddToPath "${HOME}/.dotfiles/bin" 1
AddToPath "${HOME}/personal/bin" 1
AddToPath "${HOME}/Android/Sdk/platform-tools" 1
AddToPath "${HOME}/Android/Sdk/tools" 1
AddToPath "${HOME}/bin" 1 1
AddToPath "${HOME}/.local/bin" 1
AddToPath "${HOME}/.linuxbrew/bin" 1
AddToPath "${HOME}/opt/local/bin" 1
AddToPath "/usr/local/heroku/bin" 1
AddToPath "$HOME/.cargo/bin" 1

# Mail env
export MAIL=/var/spool/mail/${USER}

# source ~/.profile_local (See example .profile_local for some variables that stuff in these scripts)
SourceFile "${HOME}/.profile_local" 1 # (1 suppresses logging on not found)

export PERL5LIB="${HOME}/perl5/lib/perl5"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

[[ -s "${ISHLIB}" ]] && CleanIshlib

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
