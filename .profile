# ~/.profile: executed by the command interpreter for login shells.
# This also gets executed when setting up the desktop...
#
# Most of the main work is done in scripts loaded by the SourceFile command.
#
# The source $ISHLIB files is used to defined some helper functions (e.g. SourceFile, AddPath),
# but no environmental variables or other side-effects get applied when it's sourced.

export EDITOR=/usr/bin/vim
export DOTFILES_HOME="${HOME}/.dotfiles"
export DOTFILES_CONFIG="${DOTFILES_HOME}/config.yaml"
export ISHLIB="${DOTFILES_HOME}/scripts/ishlib.sh"
export TMPDIR="${HOME}/tmp"
export NVM_DIR="${HOME}/.nvm"

# Load ishlib
. "${ISHLIB}" || echo "failed to source ishlib at ${ISHLIB}" > DOT_PROFILE_FAIL

# Initialize separate error log for .profile
InitErrorLog "${HOME}/.profile_errors"

# Use ishlib InitTempDir to initialize a (somewhat) private temporary directory inside /tmp
InitTempDir "${TMPDIR}"

# Applicatoin specific environment setup
SourceFile "${DOTFILES_HOME}/scripts/loadNvm.sh"
SourceFile "${DOTFILES_HOME}/startup/loadRubyGemPath.sh"
# Add some paths
AddToPath "/usr/local/heroku/bin"
AddToPath "${HOME}/personal/bin"
AddToPath "${HOME}/bin"
AddToPath "${HOME}/.local/bin" 1

# If available, source non-version-controller .profile_local
SourceFile "${HOME}/.profile_local" 1 # (1 suppresses logging on not found)

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
