#! /usr/bin/env bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

set -e

DOTFILES=${DOTFILES:-"${HOME}/.dotfiles"}

PKG_LIST_FILE=${DOTFILES}/apt_packages

# shellcheck source=../lib/checks.sh
. "${DOTFILES}/lib/checks.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

# debug_enable

NEED_INSTALL=
pkgs_dev=

do_sanity_checks() {
    if [[ ! -e ${PKG_LIST_FILE} ]]; then
        >&2 echo "Cannot find ${EXT_LIST_FILE}"
        exit 1;
    fi

    if ! has_command dpkg; then
        >&2 echo "Cannot find dpkg!"
        exit 1;
    fi
}

find_NEED_INSTALL() {
    local skip_rest=
    local x=$(running_x)
    local gnome=$(running_gnome)
    local section=

    while IFS= read -r pkg
    do
        # Ignore empty lines
        if [ -n "${pkg}" ]; then
            if [[ "${pkg}" == "[dev]" ]]; then
                section=dev
            elif [[ "${pkg}" == "[x]" ]]; then
                section=x
                ! running_x && skip_rest=1
            elif [[ "${pkg}" == "[gnome]" ]]; then
                section=gnome
                ! running_gnome && skip_rest=1
            elif [ -z "${skip_rest}" ]; then
                d_print "apt_packages.sh:${FUNCNAME[0]}: checking ${pkg}"
                if is_package_installed ${pkg}; then
                    d_print "apt_packages.sh:${FUNCNAME[0]}: ${pkg} is installed"
                else
                    d_print "apt_packages.sh:${FUNCNAME[0]}: ${pkg} is NOT installed"
                    if [[ "$section" == "dev" ]]; then
                        pkgs_dev="${pkgs_dev} ${pkg}"
                    else
                        NEED_INSTALL="${NEED_INSTALL} ${pkg}"
                    fi
                fi
            else
                d_print "apt_packages.sh:${FUNCNAME[0]}: skipping ${pkg}"
            fi
        fi
    done < "${PKG_LIST_FILE}"
}

do_sanity_checks
find_NEED_INSTALL

[[ -n "${NEED_INSTALL}" ]] && echo -e "Needed packages:\n${NEED_INSTALL}"
[[ -n "${pkgs_dev}" ]]     && echo -e "Optional dev packages:\n${pkgs_dev}"

[[ -n "${NEED_INSTALL}" ]] && exit 1
exit 0
