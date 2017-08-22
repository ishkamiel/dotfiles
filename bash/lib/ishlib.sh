_ISHLIB_ERRORFILE="${HOME}/.ishlib_errors"

InitErrorLog() {
	_ISHLIB_ERRORFILE="${1}"
	filename="${_ISHLIB_ERRORFILE}"

	if [ -e ${filename} ]; then
		mv -f "${filename}" "${filename}.bak"
	fi
}

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
	echo "$(date --rfc-3339=seconds) ${1}" >> "${_ISHLIB_ERRORFILE}"
}

AddToPath() {
	newpath="${1}"
	no_error="${2}"
	do_prepend="${3}"

	# Catch typos and bad additions
	if [ ! -e "${newpath}" ] || [ ! -d "${newpath}" ]; then
		[ ! -n "${no_error}" ] && ErrorLog "Trying to add non-existing path ${newpath}"
	elif [[ "$PATH" =~ (^|:)"${newpath}"(:|$) ]]; then
		[ $DEBUG ] && ErrorLog "Already in path ${newpath}, skipping"
	else
		if [ -n "${do_prepend}" ]; then
			export PATH="${newpath}:${PATH}"
		else
			export PATH="${PATH}:${newpath}"
		fi
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
