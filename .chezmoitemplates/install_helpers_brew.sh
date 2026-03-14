#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

brew_is_installed() {
    local pkg="$1"
    if brew list "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

brew_is_available() {
    local pkg="$1"
    if brew info "${pkg}" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

brew_install_packages() {
    for pkg in "$@"; do
        brew install "${pkg}"
    done
}

brew_install() {
    __install_packages "brew" "$@"
    return 0
}
