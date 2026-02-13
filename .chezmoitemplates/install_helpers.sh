#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

readonly ERROR_LOG="${HOME}/.chezmoi_error.log"
script_name="$(basename "$0" | sed -E 's/^[[:digit:]]+\.//')"
readonly script_name

log_error() {
    echo "[!!] ${script_name}: $*" | tee -a "${ERROR_LOG}"
}

verbose_echo() {
    if [[ ${VERBOSE:-0} == 1 ]]; then
        echo "[  ] ${script_name}: $*"
    fi
}

__install_packages() {
    local manager="$1"; shift
    local do_log_error=1
    if [[ "$1" == "0" || "$1" == "1" ]]; then
        do_log_error="$1"
        shift
    fi
    local pkgs=("$@")

    local is_installed_fn="${manager}_is_installed"; shift
    local is_available_fn="${manager}_is_available"; shift
    local install_packages="${manager}_install_packages"; shift

    declare -F "$is_installed_fn" >/dev/null || return 2
    declare -F "$is_available_fn" >/dev/null || return 2
    declare -F "$install_packages" >/dev/null || return 2

    local to_install=()
    for pkg in "${pkgs[@]}"; do
        if ! "$is_installed_fn" "$pkg"; then
            if "$is_available_fn" "$pkg"; then
                to_install+=("$pkg")
            elif [[ "$do_log_error" == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (${manager})"
            else
                verbose_echo "Skipping, cannot find ${pkg} (${manager})"
            fi
        else
            verbose_echo "Found ${pkg} (${manager})"
        fi
    done

    ((${#to_install[@]})) && "$install_packages" "${to_install[@]}"
}

downloadFile() {
    local src="${1}"
    local dst="${2}"

    if command -v curl >/dev/null 2>&1; then
        mkdir -p "$(dirname "${dst}")"
        echo "downloading ${src} to ${dst}"
        curl --progress-bar -fLo "${dst}" --create-dirs "${src}"
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p "$(dirname "${dst}")"
        wget -nv -O "${dst}" "${src}"
    else
        echo "Need either curl or wget to download ${src}"
        return 1
    fi
    return 0
}

running_gnome() {
    local old_val
    local retval=-1
    old_val=$(shopt -p nocasematch)

    shopt -s nocasematch
    [[ "${XDG_CURRENT_DESKTOP}" =~ gnome ]] && retval=0
    ${old_val}
    return ${retval}
}

# vim: set ft=bash:
