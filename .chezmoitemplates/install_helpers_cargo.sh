#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

cargo_is_installed() {
    local pkg="$1"
    cargo install --list 2>/dev/null | grep -q "^${pkg} "
}

cargo_is_available() {
    # Assume available; cargo install will error if the crate doesn't exist
    return 0
}

cargo_install_packages() {
    cargo install "$@"
}

cargo_install() {
    __install_packages "cargo" "$@"
    return 0
}
