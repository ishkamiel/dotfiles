#!/usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

readonly ERROR_LOG="${HOME}/.chezmoi_error.log"

log_error() {
    echo "[!!]: $1" | tee -a "${ERROR_LOG}"
}

is_installed_apt() {
    local pkg="$1"

    if dpkg -l | grep -q "^ii  ${pkg}[: ]"; then
        return 0
    fi
    return 1
}

is_installed_dnf() {
    local pkg="$1"

    if rpm -q "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

__install_apt_pkgs() {
    local do_log_error="$1"
    shift
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_apt "${pkg}"; then
            if apt-cache show "${pkg}" > /dev/null 2>&1; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (apt)"
            fi
        else
            echo "Found ${pkg} (apt)"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing apt packages ${to_install[*]}"
        sudo apt install -y "${to_install[@]}"
    fi
}

install_apt_pkgs() {
    __install_apt_pkgs 1 "$@"
}

install_apt_pkgs_noerr() {
    __install_apt_pkgs 0 "$@"
}

install_dnf_pkgs() {
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_dnf "${pkg}"; then
            to_install+=("${pkg}")
        else
            echo "Found ${pkg} (dnf)"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing dnf packages ${to_install[*]}"
        sudo dnf install -y "${to_install[@]}"
    fi
}

install_apt() {
    local cmd="$1"
    local pkg=${2:-$1}

    if command -v "${cmd}" >/dev/null 2>&1; then
        echo "Found ${cmd}"
        return 0
    fi

    if apt-cache show "${pkg}" > /dev/null 2>&1; then
        echo "Cannot find apt package ${pkg}"
        return 1
    fi

    echo "Installing apt package: ${pkg}"
    sudo apt install -y "${pkg}"
}

install_dnf() {
    local cmd="$1"
    local pkg=${2:-$1}

    if command -v "${cmd}" >/dev/null 2>&1; then
        echo "Found ${cmd}"
        return 0
    fi

    if dnf list "${pkg}" > /dev/null 2>&1; then
        echo "Cannot find dnf package ${pkg}"
        return 1
    fi

    echo "Installing dnf package: ${pkg}"
    sudo dnf install -y "${pkg}"
}

install_brew() {
    local cmd=$1
    local pkg=${2:-$1}

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "Found ${cmd}"
        return 0
    fi

    if ! brew info "$pkg" >/dev/null 2>&1; then
        echo "Cannot find brew package ${pkg}"
        return 1
    fi

    echo "Installing brew package: ${pkg}"
    brew install "$pkg"
}

install_pkg() {
    local cmd=$1
    local pkg=${2:-$1}
    {{ if eq .chezmoi.os "darwin" -}}
    install_brew "${cmd}" "${pkg}"
    {{ else if eq .chezmoi.osRelease.id "ubuntu" -}}
    install_apt "${cmd}" "${pkg}"
    {{ else if eq .chezmoi.osRelease.id "fedora" -}}
    install_dnf "${cmd}" "${pkg}"
    {{ end -}}
    return $?
}

# vim: set ft=bash:
