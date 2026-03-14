#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

snap_is_installed() {
    local pkg="$1"
    if snap list "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

snap_is_available() {
    local pkg="$1"
    if snap info "${pkg}" &>/dev/null; then
        return 0
    fi
    return 1
}

snap_install_packages() {
    sudo snap install "$@"
}

snap_install() {
    __install_packages "snap" "$@"
    return 0
}
