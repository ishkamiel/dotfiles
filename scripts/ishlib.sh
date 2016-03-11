#! /bin/sh

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
