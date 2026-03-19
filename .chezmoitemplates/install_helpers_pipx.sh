#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

pipx_is_installed() {
    pipx list --short 2>/dev/null | grep -q "^$1 "
}

pipx_is_available() {
    # Assume available; pipx will error if the package doesn't exist
    return 0
}

pipx_install_packages() {
    local result=0
    for pkg in "$@"; do
        pipx install "$pkg" || result=$?
    done
    return $result
}

pipx_install() {
    __install_packages "pipx" "$@"
    return 0
}
