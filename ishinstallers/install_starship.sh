#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Custom installer for starship prompt.
# Uses the official upstream install script.

: <<'__ISH__'
cmd = "starship"
__ISH__

set -euo pipefail

if command -v starship >/dev/null 2>&1; then
  ish_info "starship already installed: $(starship --version 2>/dev/null | head -1)"
  exit 0
fi

ish_info "Installing starship via upstream install script"
mkdir -p "${HOME}/bin"
if ! curl -sS https://starship.rs/install.sh | sh -s -- -b "${HOME}/bin" -y; then
  ish_error "Failed to install starship"
  exit 1
fi

ish_info "starship installed: $(starship --version 2>/dev/null | head -1)"
