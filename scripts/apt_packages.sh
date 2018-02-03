#!/bin/bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.


PKG_LIST_FILE=${DOTFILES}/apt_packages

[[ -z "${LIB_CHECKS_SH}" ]] && source "${DOTFILES_BASH}/lib/checks.sh"
[[ -z "${LIB_DEBUG_SH}" ]] && source "${DOTFILES_BASH}/lib/debug.sh"

# debug_enable

NEED_INSTALL=

do_sanity_checks() {
    if [[ ! -e ${PKG_LIST_FILE} ]]; then
        >&2 echo "Cannot find ${EXT_LIST_FILE}"
        exit -1;
    fi

    if ! has_command dpkg; then
        >&2 echo "Cannot find dpkg!"
        exit -1;
    fi
}

find_NEED_INSTALL() {
    local skip_rest=
    local x=$(running_x)
    local gnome=$(running_gnome)

    while IFS= read -r pkg
    do
        # Ignore empty lines
        if [ -n "${pkg}" ]; then
            if [[ "${pkg}" == "[x]" ]]; then
                ! running_x && skip_rest=1
            elif [[ "${pkg}" == "[gnome]" ]]; then
                ! running_gnome && skip_rest=1
            elif [ -z "${skip_rest}" ]; then
                d_print "apt_packages.sh:${FUNCNAME[0]}: checking ${pkg}"
                if is_package_installed ${pkg}; then
                    d_print "apt_packages.sh:${FUNCNAME[0]}: ${pkg} is installed"
                else
                    d_print "apt_packages.sh:${FUNCNAME[0]}: ${pkg} is NOT installed"
                    NEED_INSTALL="${NEED_INSTALL} ${pkg}"
                fi
            else
                d_print "apt_packages.sh:${FUNCNAME[0]}: skipping ${pkg}"
            fi
        fi
    done < "${PKG_LIST_FILE}"
}

do_sanity_checks
find_NEED_INSTALL

if [ -n "${NEED_INSTALL}" ]; then
    echo -e "Needed packages:\n${NEED_INSTALL}"
    exit -1
fi
exit 0
