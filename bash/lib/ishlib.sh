#!/bin/dash

LIB_ISHLIB_SH=1

[ -z "${ISH_LOGFILE_FN}" ] && ISH_LOGFILE_FN='.ishlib_errors'
[ -z "${_ISHLIB_ERRORFILE}" ] && export _ISHLIB_ERRORFILE="${HOME}/${ISH_LOGFILE_FN}"

# Max logsize in bytes
MAX_LOGSIZE=100000

ErrorLog() {
	local msg="$(date --rfc-3339=seconds) <$$> [!!]: ${1}"

	if [ -n "${DEBUG}" ] && [ "${DEBUG}" -ne 0 ]; then
		echo "${msg}" | tee -a "${_ISHLIB_ERRORFILE}"
	else
		echo "${msg}" >> "${_ISHLIB_ERRORFILE}"
	fi
}

IshDebugPrint() {
	local msg="$(date --rfc-3339=seconds) <$$> [DD]: ${1} "

	if [ -n "${DEBUG}" ] && [ "${DEBUG}" -ne 0 ]; then
		echo "${msg}" | tee -a "${_ISHLIB_ERRORFILE}"
	else
		echo "${msg}" >> "${_ISHLIB_ERRORFILE}"
	fi
}

ish_checkLogSize() {
    local log_size=$(wc -c "${_ISHLIB_ERRORFILE}" | awk '{print $1}')

    if [ "${log_size}" -gt "${MAX_LOGSIZE}" ]; then
        mv "${_ISHLIB_ERRORFILE}" "${_ISHLIB_ERRORFILE}.bak"
    fi
}

ish_setLogFile() {
    local logfile=$1

    if [ "${logfile}" != "${_ISHLIB_ERRORFILE}" ]; then
        IshDebugPrint "relocating log to $logfile"

        if [ -e "${_ISHLIB_ERRORFILE}" ]; then
            cat "${_ISHLIB_ERRORFILE}" >> ${logfile}
            /bin/rm ${_ISHLIB_ERRORFILE}
            export _ISHLIB_ERRORFILE="${logfile}"
        fi

        IshDebugPrint "logfile moved to $logfile"
    fi

    ish_checkLogSize
}

# Tries to create temporary directory at $1, unless it already exists. If
# directory is created in system tmp, also tries to set permissions with
# setfacl. In cases of falure, simply creates a regular directory at tmp.
# (NOTE: fallback regular directory will not be deleted/cleared on reboot).
InitTempDir() {
	local tempdir=${1}

	if [ ! -e ${tempdir} ] || [ ! -O ${tempdir} ]; then
		# Remove possibe dead link
		[ -L ${tempdir} ] && rm -f ${tempdir}

		if command -v mktemp > /dev/null; then

            local tmp_tmpdir=$TMPDIR
			unset TMPDIR # Need to unset for mktmp
			ln -s $(mktemp -d) ${tempdir}
            [ -z "${tmp_tmpdir}" ] && export TMPDIR="${tmp_tmpdir}"

			if command -v setfacl > /dev/null; then
				setfacl -d -m o::- "${tempdir}/."
			else
				ErrorLog "Cannot execute setfacl"
			fi
		else
			ErrorLog "Cannot execute mktemp"
			mkdir -p ${tempdir}
		fi
	fi

    if [ -e ${tmpdir} ]; then
        export TMPDIR=${tempdir}
        ish_setLogFile "${TMPDIR}/${ISH_LOGFILE_FN}"
    fi
}

ish_testPathOk() {
    if [ ! -e "${newpath}" ] || [ ! -d "${newpath}" ]; then
        ErrorLog "Trying to add non-existing path '${newpath}'"
        return 1
    elif echo "$PATH" | /bin/grep -Eq "(^|:)${newpath}($|:)" ; then
        ErrorLog "Already in path '${newpath}', skipping"
        return 1
    fi
    echo "exit ok testPath"
    return 0
}

ish_insertPath() {
    local newpath=$1

    if ish_testPathOk $1; then
        IshDebugPrint "prepending ${newpath} to \$PATH"
        export PATH="${newpath}:${PATH}"
        return 0
    fi
	return -1
}

ish_appendPath() {
    local newpath=$1

    if ish_testPathOk $1; then
        IshDebugPrint "prepending ${newpath} to \$PATH"
        export PATH="${newpath}:${PATH}"
        return 0
    fi
	return -1
}

ish_sourceFile() {
	local filename="${1}"

	if [ ! -s "${filename}" ]; then
		IshDebugPrint "SourceFile cannot find ${filename}"
        return 1
    fi

    . ${filename}
}
ish_requireFile() {
	local filename="${1}"

	if [ ! -s "${filename}" ]; then
		ErrorLog "SourceFile cannot find ${filename}"
        return 1
    fi

    . ${filename}
}

CleanIshlib() {
	IshDebugPrint "ishlib cleaning up"
    ish_checkLogSize
	unset -f ErrorLog
	unset -f InitErrorLog
	unset -f InitTempDir
	unset -f IshDebugPrint
	unset -f ish_sourceFile
	unset -f ish_requireFile
	unset -f ish_testPath
	unset -f ish_insertPath
	unset -f ish_appendPath
	unset -f ish_checkLogSize
    unset -f ish_setLogFile
}

IshDebugPrint "ishlib loaded by $0, logging to ${_ISHLIB_ERRORFILE}"
