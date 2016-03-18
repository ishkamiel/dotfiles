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

    unset -f loadNVM
    unset -f loadRuby
}

# }}}
loadNVM() { # {{{
    local NVM_DIR=${1}

    if [ -s "${NVM_DIR}/nvm.sh" ]; then
        . "${NVM_DIR}/nvm.sh"
    else
        ErrorLog "Couldn't find nvm at ${NVM_DIR}"
    fi
} # }}}
loadRuby() { # {{{
    local gempath="${1}"

    if [ -e "${gempath}" ]; then
        local ruby_version=$(ls ${gempath} | sort | tail -n 1);
        local gem_bin="${gempath}/${ruby_version}/bin"
        AddToPath "${gem_bin}"
    else
        ErrorLog "Cannot find Ruby in ${gempath}"
    fi
} # }}}

export EDITOR=/usr/bin/vim

# Initialize separate error log for .profile
InitErrorLog "${HOME}/.profile_errors"

# Use ishlib InitTempDir to initialize a (somewhat) private temporary directory inside /tmp
InitTempDir "${HOME}/tmp"

# Applicatoin specific environment setup
loadNVM "${HOME}/.nvm"
# loadRuby "${HOME}/.gem/ruby"

# Add some paths
AddToPath "${HOME}/personal/bin" 1
AddToPath "${HOME}/bin" 1
AddToPath "${HOME}/.local/bin" 1
AddToPath "/usr/local/heroku/bin" 1

# If available, source non-version-controller .profile_local
SourceFile "${HOME}/.profile_local" 1 # (1 suppresses logging on not found)

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# vim: ft=sh fdm=marker foldlevel=0
