# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export EDITOR=/usr/bin/vim
export DOTFILES_HOME="${HOME}/.dotfiles"
export ISHLIB="${DOTFILES_HOME}/scripts/ishlib.sh"
export TMPDIR="${HOME}/tmp"

# Load ishlib
. "${ISHLIB}" || echo "failed to source ishlib at ${ISHLIB}" > DOT_PROFILE_FAIL

# Initialize error log and temporary directory
InitErrorLog "${HOME}/.profile_errors"
InitTempDir "${TMPDIR}"

# Source applicatoin specific environment setup
SourceFile "${DOTFILES_HOME}/startup/p.heroku.sh"
SourceFile "${DOTFILES_HOME}/startup/p.nvm.sh"
SourceFile "${DOTFILES_HOME}/startup/p.ruby.sh"

# If available, source non-version-controller .profile_local
SourceFile "${HOME}/.profile_local" 1

# Add some paths
AddToPath "${HOME}/personal/bin"
AddToPath "${HOME}/bin"
AddToPath "${HOME}/.local/bin" 1



# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

