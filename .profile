# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4
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
			ln -s $(mktemp -d) ${tempdir}
			if command -v setfacl > /dev/null; then
				setfacl -d -m o::- "${tempdir}/."
			else
				ErrorLog "Cannot execute setfacl"
				mkdir -p ${1}
			fi
		else
			ErrorLog "Cannot execute mktemp"
			mkdir -p ${1}
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
# }}}

export EDITOR=/usr/bin/vim
export DOTFILES="${HOME}/.dotfiles"
export DOTFILES_BASH="${DOTFILES}/bash"
export TMPDIR="${HOME}/tmp"
export LOGDIR="${TMPDIR}/log"
export VIMBACKUP="${TMPDIR}/vimbackup"

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

# Mail env
export MAIL=/var/spool/mail/${USER}

# Source .bashrc if running bash (not sure if this is needed?)
[ -n "${BASH_VERSION}" ] && [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"

# source ~/.profile_local (See example .profile_local for some variables that stuff in these scripts)
SourceFile "${HOME}/.profile_local" 1 # (1 suppresses logging on not found)

export PERL5LIB="${HOME}/perl5/lib/perl5"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

####################################################################################################
# Unset functions so they don't escape
CleanIshlib

