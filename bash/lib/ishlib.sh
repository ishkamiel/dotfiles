
export _ISHLIB_ERRORFILE="${HOME}/.ishlib_errors"

# Tries to create temporary directory at $1, unless it already exists. If
# directory is created in system tmp, also tries to set permissions with
# setfacl. In cases of falure, simply creates a regular directory at tmp.
# (NOTE: fallback regular directory will not be deleted/cleared on reboot).
InitTempDir() {
	tempdir=${1}

	if [ ! -e ${tempdir} ] || [ ! -O ${tempdir} ]; then
		# Remove possibe dead link
		[ -L ${tempdir} ] && rm -f ${tempdir}

		if command -v mktemp > /dev/null; then

			unset TMPDIR # Need to unset for mktmp
			ln -s $(mktemp -d) ${tempdir}
			export TMPDIR=${tempdir}

			if command -v setfacl > /dev/null; then
				setfacl -d -m o::- "${tempdir}/."
			else
				ErrorLog "Cannot execute setfacl"
				mkdir -p ${tempdir}
			fi
		else
			ErrorLog "Cannot execute mktemp"
			mkdir -p ${tempdir}
		fi
	fi
}

ErrorLog() {
	local msg="$(date --rfc-3339=seconds) [!!]: ${1}"

	if [ -n "${DEBUG}" ] && [ "${DEBUG}" -ne 0 ]; then
		echo "${msg}" | tee -a "${_ISHLIB_ERRORFILE}"
	else
		echo "${msg}" >> "${_ISHLIB_ERRORFILE}"
	fi
}

IshDebugPrint() {
	local msg="$(date --rfc-3339=seconds) [DD]: ${1} "

	if [ -n "${DEBUG}" ] && [ "${DEBUG}" -ne 0 ]; then
		echo "${msg}" | tee -a "${_ISHLIB_ERRORFILE}"
	else
		echo "${msg}" >> "${_ISHLIB_ERRORFILE}"
	fi
}

AddToPath() {
	local newpath="${1}"
	local no_error="${2}"
	local do_prepend="${3}"

	[ -z "${no_error}" ] && local no_error=0
	[ -z "${do_prepend}" ] && local no_error=0

	# Catch typos and bad additions
	if [ ! -e "${newpath}" ] || [ ! -d "${newpath}" ]; then
		[ "${no_error}" -eq 1 ] || ErrorLog "Trying to add non-existing path '${newpath}'"
		return 1
        elif echo "$PATH" | /bin/grep -Eq "(^|:)${newpath}($|:)" ; then
		[ "${no_error}" -eq 1 ] && ErrorLog "Already in path '${newpath}', skipping"
		return 1
	else
		if [ "${do_prepend}" -eq 1 ]; then
			IshDebugPrint "prepending ${newpath} to \$PATH"
			export PATH="${newpath}:${PATH}"
		else
			IshDebugPrint "appending ${newpath} to \$PATH"
			export PATH="${PATH}:${newpath}"
		fi
		return 0
	fi
}

IshInsertPath() {
	AddToPath "${1}" 1 1
	return $?
}

IshAppendPath() {
	AddToPath "${1}" 1 0
	return $?
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
	IshDebugPrint "ishlib cleaning up"
	/bin/mv -f "${_ISHLIB_ERRORFILE}" "${_ISHLIB_ERRORFILE}.bak"
	unset -f AddToPath
	unset -f ErrorLog
	unset -f InitErrorLog
	unset -f InitTempDir
	unset -f SourceFile
	unset -f CleanIshlib
	unset -f IshDebugPrint
	unset -f IshInsertPath
	unset -f IshAppendPath
}


IshDebugPrint "ishlib loaded by $0, logging to ${_ISHLIB_ERRORFILE}"
