#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Custom installer for rustup.
# Falls back to the upstream rustup-init script when the distro package is
# unavailable (e.g., older Ubuntu releases without rustup in their repos).

set -euo pipefail

ish_info "Installing rustup via upstream rustup-init script"
if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path --default-toolchain stable; then
  ish_error "Failed to install rustup"
  exit 1
fi
