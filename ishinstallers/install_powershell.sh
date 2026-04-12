#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Custom installer for PowerShell (pwsh) on Debian-family Linux.
# Uses the Microsoft package repository.

: <<'__ISH__'
cmd = "pwsh"
only_on = ["debian"]
__ISH__

set -euo pipefail

# Source the package_repos helpers if ISHLIB is set; otherwise define stubs so
# the script is self-contained for testing.
if [[ -n "${ISHLIB:-}" ]] && [[ -f "${ISHLIB}/src/bash/package_repos.bash" ]]; then
  # shellcheck source=/dev/null
  . "${ISHLIB}/src/bash/package_repos.bash"
fi

if command -v pwsh >/dev/null 2>&1; then
  ish_info "PowerShell already installed: $(pwsh --version 2>/dev/null)"
  exit 0
fi

ish_info "Installing PowerShell via Microsoft apt repository"

# Load /etc/os-release for $ID and $VERSION_ID
# shellcheck source=/dev/null
source /etc/os-release

_ms_key_url="https://packages.microsoft.com/keys/microsoft.asc"
_ms_keyring="/etc/apt/keyrings/microsoft.gpg"
_ms_repo_name="microsoft-prod"
_ms_deb_line="deb [arch=$(dpkg --print-architecture) signed-by=${_ms_keyring}] \
https://packages.microsoft.com/repos/microsoft-${ID}-${VERSION_ID}-prod ${VERSION_CODENAME:-${VERSION_ID}} main"

if ! ish_apt_add_key "${_ms_key_url}" "microsoft"; then
  ish_error "Failed to add Microsoft GPG key"
  exit 1
fi

if ! ish_apt_add_repo "${_ms_repo_name}" "${_ms_deb_line}"; then
  ish_error "Failed to add Microsoft apt repository"
  exit 1
fi

if ! sudo apt-get install -y powershell; then
  ish_error "Failed to install powershell via apt"
  exit 1
fi

ish_info "PowerShell installed: $(pwsh --version 2>/dev/null)"
