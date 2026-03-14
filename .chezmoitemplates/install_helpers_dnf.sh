#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

dnf_is_installed() {
    local pkg="$1"
    if rpm -q "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

dnf_is_available() {
    local pkg="$1"
    if dnf list --available "${pkg}" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

dnf_install_packages() {
    sudo dnf install -y "$@"
}

dnf_install() {
    __install_packages "dnf" "$@"
    return 0
}
