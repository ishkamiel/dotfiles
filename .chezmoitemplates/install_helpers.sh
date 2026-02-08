#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

readonly ERROR_LOG="${HOME}/.chezmoi_error.log"

readonly CHEZMOI_OS="{{ .chezmoi.os }}"
{{ if eq .chezmoi.os "linux" }}
readonly CHEZMOI_OSRELEASE="{{ .chezmoi.osRelease.id }}"
{{ else }}
readonly CHEZMOI_OSRELEASE=""
{{ end }}

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

is_installed_winget() {
    local pkg="$1"

    if winget list --id "${pkg}" --source winget 2>/dev/null | grep -qi "${pkg}"; then
        return 0
    fi
    return 1
}

is_installable_winget() {
    local pkg="$1"
    if winget show --id "${pkg}" --source winget >/dev/null 2>&1; then
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
            else
                echo "Skipping, cannot find ${pkg} (apt)"
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
    local do_log_error="$1"
    shift
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_dnf "${pkg}"; then
            if is_installable_dnf "${pkg}"; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (dnf)"
            else
                echo "Skipping, cannot find ${pkg} (dnf)"
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
    local do_log_error="$1"
    shift
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_snap "${pkg}"; then
            if is_installable_snap "${pkg}"; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (snap)"
            else
                echo "Skipping, cannot find ${pkg} (snap)"
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

__install_winget_pkgs() {
    local do_log_error="$1"
    shift
    local pkgs=("$@")
    local to_install=()

    for pkg in "${pkgs[@]}"; do
        if ! is_installed_winget "${pkg}"; then
            if is_installable_winget "${pkg}"; then
                to_install+=("${pkg}")
            elif [[ ${do_log_error} == 1 ]]; then
                log_error "Cannot find pkg to install: ${pkg} (winget)"
            fi
        else
            echo "Found ${pkg} (winget)"
        fi
    done

    if [ ${#to_install[@]} -ne 0 ]; then
        echo "Installing winget packages ${to_install[*]}"
        for pkg in "${to_install[@]}"; do
            if ! winget install --id "${pkg}" --source winget --accept-source-agreements --accept-package-agreements; then
                if [[ ${do_log_error} == 1 ]]; then
                    log_error "Failed to install: ${pkg} (winget)"
                fi
            fi
        done
    fi
}

install_winget_pkgs() {
    __install_winget_pkgs 1 "$@"
}

install_winget_pkgs_noerr() {
    __install_winget_pkgs 0 "$@"
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

install_winget() {
    local cmd="$1"
    local pkg=${2:-$1}

    if command -v "${cmd}" >/dev/null 2>&1; then
        echo "Found ${cmd}"
        return 0
    fi

    if ! is_installable_winget "${pkg}"; then
        echo "Cannot find winget package ${pkg}"
        return 1
    fi

    echo "Installing winget package: ${pkg}"
    if ! winget install --id "${pkg}" --source winget --accept-source-agreements --accept-package-agreements; then
        log_error "Failed to install: ${pkg} (winget)"
        return 1
    fi
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

    if [[ ${CHEZMOI_OS} == "linux" ]]; then
        if [[ ${CHEZMOI_OSRELEASE} == "ubuntu" ]]; then
            install_apt "${cmd}" "${pkg}"
            return $?
        elif [[ ${CHEZMOI_OSRELEASE} =~ ^fedora ]]; then
            install_dnf "${cmd}" "${pkg}"
            return $?
        fi
    elif [[ ${CHEZMOI_OS} == "darwin" ]]; then
        install_brew "${cmd}" "${pkg}"
        return $?
    elif [[ ${CHEZMOI_OS} == "windows" ]]; then
        install_winget "${cmd}" "${pkg}"
        return $?
    else
        log_error "Cannot determine installer in install_pkg"
    fi
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
