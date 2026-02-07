#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

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
    if snap list "${pkg}" &>/dev/null; then
        return 0
    fi
    return 1
}

is_installed_snap() {
    local pkg="$1"

    if rpm -q "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}


is_installable_apt() {
    local pkg="$1"
    if apt-cache show "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

is_installable_dnf() {
    local pkg="$1"
    if dnf list --available "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

is_installable_snap() {
    local pkg="$1"
    if snap info "${pkg}" &>/dev/null; then
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
            if is_installable_apt "${pkg}"; then
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

__install_dnf_pkgs() {
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_dnf "${pkg}"; then
            if is_installable_dnf "${pkg}"; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (dnf)"
            fi
        else
            echo "Found ${pkg} (dnf)"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing dnf packages ${to_install[*]}"
        sudo dnf install -y "${to_install[@]}"
    fi
}

install_dnf_pkgs() {
    __install_dnf_pkgs 1 "$@"
}

install_dnf_pkgs_noerr() {
    __install_dnf_pkgs 0 "$@"
}

__install_snap_pkgs() {
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_snap "${pkg}"; then
            if is_installable_snap "${pkg}"; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (snap)"
            fi
        else
            echo "Found ${pkg} (snap)"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing snap packages ${to_install[*]}"
        sudo snap install -y "${to_install[@]}"
    fi
}

install_snap_pkgs() {
    __install_snap_pkgs 1 "$@"
}

install_snap_pkgs_noerr() {
    __install_snap_pkgs 0 "$@"
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

downloadFile() {
    local src="${1}"
    local dst="${2}"

    if command -v curl >/dev/null 2>&1; then
        mkdir -p $(dirname "${dst}")
        echo "downloading ${src} to ${dst}"
        curl --progress-bar -fLo "${dst}" --create-dirs "${src}"
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p $(dirname "${dst}")
        wget -nv -O "${dst}" "${src}"
    else
        echo "Need either curl or wget to download ${src}"
        return 1
    fi
    return 0
}

running_gnome() {
    local old_val=$(shopt -p nocasematch)
    local retval=-1

    shopt -s nocasematch
    [[ "${XDG_CURRENT_DESKTOP}" =~ gnome ]] && retval=0
    ${old_val}
    return ${retval}
}

# vim: set ft=bash:
