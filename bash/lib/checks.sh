#!/bin/bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

LIB_CHECKS_SH=1

[[ -z "${LIB_DEBUG_SH}" ]] && source "${DOTFILES_BASH}/lib/debug.sh"

running_gnome() {
    local old_val=$(shopt -p nocasematch)
    local retval=-1

    shopt -s nocasematch
    [[ "${XDG_CURRENT_DESKTOP}" =~ gnome ]] && retval=0
    ${old_val}
    return ${retval}
}

running_x() {
    # TODO: actually check something...
    running_gnome
    return $?
}

has_command() {
    local cmd="$1"

    d_print "checks.sh:${FUNCNAME[0]}: looking for ${cmd}"
    [[ -n "${cmd}" ]] || (>&2 echo "checks.sh:${FUNCNAME[0]}: missing argument"; return -1)

    if command -v ${cmd} >/dev/null 2>&1; then
        d_print "checks.sh:${FUNCNAME[0]}: found ${cmd}"
        return 0
    fi

    d_print "checks.sh:${FUNCNAME[0]}: failed to find ${cmd}"
    return -1
}

is_package_installed() {
    local pkg="$1"

    [[ -n "${pkg}" ]] || (>&2 echo "checks.sh:${FUNCNAME[0]}: missing argument" && return -1)

    if has_command dpkg; then
        if  dpkg -s ${pkg} &> /dev/null; then
            return 0;
        fi
        return -1
    fi

    >&2 echo "checks.sh:${FUNCNAME[0]}: cannot find dpkg"
    return -1
}
