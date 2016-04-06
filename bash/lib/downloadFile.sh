#!/bin/sh

downloadFile() {
	local src="${1}"
	local dst="${2}"

	[[ -z $src ]] && >&2 echo "downloadFile(src, dst): missing src!"
	[[ -z $dst ]] && >&2 echo "downloadFile(src, dst): missing dst!"
	if [[ -z $src ]] || [[ -z $dst ]]; then return 1; fi


	if command -v curl >/dev/null 2>&1
	then
    	curl --progress-bar -fLo "${dst}" --create-dirs "${src}"
	elif command -v wget >/dev/null 2>&1
	then
		wget -O "${dst}" "${src}"
	else
		echo "Need either curl or wget to download ${src}"
		return 1
	fi
	return 0
}
