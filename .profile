# vim: fdm=marker foldlevel=0
# ~/.profile: executed by the command interpreter for login shells (and desktop :) )

# Generic helper functions (ishlib) {{{

_ISHLIB_ERRORFILE="${HOME}/.ishlib_errors"

InitErrorLog() {
    _ISHLIB_ERRORFILE="${1}"
    filename="${_ISHLIB_ERRORFILE}"

    if [ -e ${filename} ]; then
        mv -f "${filename}" "${filename}.bak"
    fi
}

ErrorLog() {
    echo "$(date --rfc-3339=seconds) ${1}" >> "${_ISHLIB_ERRORFILE}"
}

InitTempDir() {
    tempdir=${1}

    if [ ! -e ${tempdir} ] || [ ! -O ${tempdir} ]; then
        # Remove possibe dead link
        [ -L ${tempdir} ] && rm -f ${tempdir}

        if command -v mktemp > /dev/null; then
            ln -s $(mktemp -d) ${tempdir}
            if command -v setfacl > /dev/null; then
                setfacl -d -m o::- "${tempdir}/."
            else
                ErrorLog "Cannot execute setfacl"
            fi
            mkdir ${tempdir}/vimbackup
        else
            ErrorLog "Cannot execute mktemp"
        fi
    fi

    export TMPDIR="${1}"
}

AddToPath() {
    newpath="${1}"
    no_error="${2}"

    # Catch typos and bad additions
    if [ ! -e "${newpath}" ] || [ ! -d "${newpath}" ]; then
        [ ! -n "${no_error}" ] && ErrorLog "Trying to add non-existing path ${newpath}"
    elif [[ "$PATH" =~ (^|:)"${newpath}"(:|$) ]]; then
        [ $DEBUG ] && ErrorLog "Already in path ${newpath}, skipping"
    else
        export PATH="$PATH:${newpath}"
    fi
}

SourceFile() {
    filename="${1}"
    no_error="${2}"

    if [ -s "${filename}" ]; then
        . ${filename}
    elif [ ! -n "${no_error}" ]; then
        ErrorLog "SourceFile cannot find ${filename}"
    fi
}

CleanIshlib() {
    unset -f AddToPath
    unset -f ErrorLog
    unset -f InitErrorLog
    unset -f InitTempDir
    unset -f SourceFile
    unset -f CleanIshlib
}
# }}}

export EDITOR=/usr/bin/vim
export DOTFILES="${HOME}/.dotfiles"
export DOTFILES_BASH="${DOTFILES}/bash"

# Initialize separate error log for .profile
InitErrorLog "${HOME}/.profile_errors"

# Use ishlib InitTempDir to initialize a (somewhat) private temporary directory inside /tmp
InitTempDir "${HOME}/tmp"

# NVM (Node version manager)
[[ -s "${NVM_DIR}/nvm.sh" ]] && . "${NVM_DIR}/nvm.sh"

# RVM
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Add some paths
AddToPath "${HOME}/.dotfiles/bin" 1
AddToPath "${HOME}/bin" 1
AddToPath "${HOME}/.local/bin" 1
AddToPath "/usr/local/heroku/bin" 1

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# source ~/.profile_local (See example .profile_local for some variables that stuff in these scripts)
SourceFile "${HOME}/.profile_local" 1 # (1 suppresses logging on not found)

export PERL5LIB="${HOME}/perl5/lib"

####################################################################################################
# Unset functions so they don't escape
CleanIshlib

