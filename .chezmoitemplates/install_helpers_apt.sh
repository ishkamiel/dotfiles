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
    sudo apt install -y "$@"
}

apt_install() {
    __install_packages "apt" "$@"
    return 0
}
