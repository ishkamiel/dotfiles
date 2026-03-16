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
    confirm_action "run: sudo dnf install -y $*?" || return 1
    sudo dnf install --skip-broken -y "$@"
}

dnf_install() {
    __install_packages "dnf" "$@"
    return 0
}

# dnf_import_key KEY_URL KEY_NAME
# Imports a GPG key by URL if not already imported, with confirmation.
# KEY_NAME is a substring to match in `rpm -q gpg-pubkey` output (e.g. "Microsoft").
dnf_import_key() {
    local url="$1"
    local key_name="$2"
    if rpm -q gpg-pubkey --qf '%{summary}\n' 2>/dev/null | grep -qi "${key_name}"; then
        verbose_echo "GPG key '${key_name}' already imported"
        return 0
    fi
    confirm_action "Import GPG key '${key_name}' from ${url}?" || return 1
    if ! sudo rpm --import "${url}"; then
        log_error "Failed to import GPG key from ${url}"
        return 1
    fi
}

# dnf_add_repo REPO_FILE CONTENT
# Creates a dnf .repo file if not already present, with confirmation.
# CONTENT is passed as a heredoc-style string (use printf for multiline).
dnf_add_repo() {
    local repo_file="$1"
    local content="$2"
    if [[ -f "${repo_file}" ]]; then
        verbose_echo "dnf repository already present at ${repo_file}"
        return 0
    fi
    confirm_action "Add dnf repository to ${repo_file}?" || return 1
    printf '%s\n' "${content}" | sudo tee "${repo_file}" > /dev/null
    sudo -k
}
