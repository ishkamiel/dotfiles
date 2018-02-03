#!/bin/bash
#
# Extension installation based on: thefekete/gnome-ext-install.sh
# https://gist.github.com/thefekete/d0d7195783b216e0d67a6d56f19207ee
#
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#

[[ -z "${LIB_CHECKS_SH}" ]] && source "${DOTFILES_BASH}/lib/checks.sh"
[[ -z "${LIB_DEBUG_SH}" ]] && source "${DOTFILES_BASH}/lib/debug.sh"

debug_enable

EXT_TOOL=gnome-shell-extension-tool

EXT_LIST_FILE=${DOTFILES}/gnome-shell-extensions
SYSTEM_EXT_DIR=/usr/share/gnome-shell/extensions
USER_EXT_DIR="${HOME}/.local/share/gnome-shell/extensions"

GNOME_SHELL_VERSION=$(gnome-shell --version | cut -d' ' -f3)
EXT_BASE_URL="https://extensions.gnome.org"

do_sanity_checks() {
    if ! running_gnome; then
        >&2 echo "Not running gnome-shell, skipping..."
        exit 0;
    fi

    if ! has_command ${EXT_TOOL}; then
        >&2 echo "Cannot find ${EXT_TOOL}!"
        exit -1;
    fi

    if [[ ! -e ${EXT_LIST_FILE} ]]; then
        >&2 echo "Cannot find ${EXT_LIST_FILE}"
        exit -1;
    fi
}

ext_is_installed() {
    local ext=$1
    local retval=-1
    [[ -n "${ext}" ]] || (>&2 echo "gnome-shell-extensions.sh:${FUNCNAME[0]}: missing argument"; return -1)

    if [[ -e "${SYSTEM_EXT_DIR}/${ext}" ]]; then
        d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: ${ext} installed system-wide"
        retval=0
    fi

    if [[ -e "${USER_EXT_DIR}/${ext}" ]]; then
        d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: ${ext} installed for user"
        retval=0
    fi

    return ${retval}
}

get_dl_link () {
    local ext=$1

    [[ -n "${ext}" ]] || (>&2 echo "gnome-shell-extensions.sh:${FUNCNAME[0]}: missing argument"; return -1)

}

download_and_install() {
    local ext=$1
    local retval=-1
    local info_url="${EXT_BASE_URL}/extension-info/?uuid=${ext}&shell_version=${GNOME_SHELL_VERSION}"
    local install_dir="${USER_EXT_DIR}/${ext}"

    [[ -n "${ext}" ]] || (>&2 echo "gnome-shell-extensions.sh:${FUNCNAME[0]}: missing argument"; return -1)

    if ! has_command curl; then
        >&2 echo "cannot find curl, unable to install ${ext}"
        return -1
    fi

    local tmpdir=$(mktemp -d)
    local zip_fn="${tmpdir}/${ext}.zip"

    d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: getting download URL fo ${ext}"

    local dl_url="${EXT_BASE_URL}$(curl -s "$info_url" \
        | sed -e 's/.*"download_url": "\([^"]*\)".*/\1/')"

    trap "rm -rf ${tmpdir}" EXIT

    d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: downloading ${dl_url}"
    curl -s -L "${dl_url}" > "${zip_fn}"

    d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: unzipping to ${install_dir}"
    unzip "${zip_fn}" -d "${install_dir}"
    retval=$?

    rm -rf ${tmpdir}
    trap '' EXIT
    return ${retval}
}

check_extensions() {
    while IFS= read -r ext
    do
        d_print "gnome-shell-extensions.sh:${FUNCNAME[0]}: checking ${ext}"

        if ext_is_installed ${ext}; then
            ${EXT_TOOL} -e ${ext} > /dev/null 2>&1
        elif download_and_install ${ext}; then
            >&2 echo "${ext} installed"
            ${EXT_TOOL} -e ${ext}
        else
            >&2 echo "failed to setup ${ext}"
        fi
    done < "${EXT_LIST_FILE}"
}

do_sanity_checks
check_extensions

exit 0
