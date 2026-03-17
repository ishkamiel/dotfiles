#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

apt_is_installed() {
    local pkg="$1"
    if dpkg -l | grep -q "^ii  ${pkg}[: ]"; then
        return 0
    fi
    return 1
}

apt_is_available() {
    local pkg="$1"
    if apt-cache show "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

apt_install_packages() {
    confirm_action "run: sudo apt install -y $*?" || return 1
    echo "sudo apt install -y $*"
    sudo apt install -y "$@"
}

apt_install() {
    __install_packages "apt" "$@"
    return 0
}

# apt_add_key KEY_URL DEST_PATH
# Downloads and installs a GPG key if not already present, with confirmation.
apt_add_key() {
    local url="$1"
    local dest="$2"
    if [[ -f "${dest}" ]]; then
        verbose_echo "GPG key already present at ${dest}"
        return 0
    fi
    confirm_action "Add GPG key to ${dest}?" || return 1
    if ! curl -sSL "${url}" | sudo tee "${dest}" > /dev/null; then
        log_error "Failed to download GPG key from ${url}"
        return 1
    fi
}

# apt_add_ppa PPA
# Adds an Ubuntu PPA if not already present, with confirmation.
apt_add_ppa() {
    local ppa="$1"
    local ppa_name="${ppa#ppa:}"
    if grep -rqs "${ppa_name}" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
        verbose_echo "PPA already present: ${ppa}"
        return 0
    fi
    confirm_action "Add PPA ${ppa}?" || return 1
    sudo add-apt-repository -y "${ppa}"
    sudo apt-get update -q
}

# apt_add_repo REPO_LINE LIST_FILE
# Adds an apt repository source file if not already present, with confirmation.
apt_add_repo() {
    local repo_line="$1"
    local list_file="$2"
    if [[ -f "${list_file}" ]]; then
        verbose_echo "apt repository already present at ${list_file}"
        return 0
    fi
    confirm_action "Add apt repository to ${list_file}?" || return 1
    echo "${repo_line}" | sudo tee "${list_file}" > /dev/null
    sudo apt-get update -q
}
