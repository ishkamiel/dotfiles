#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Post-install setup for fzf key-bindings and completion.
# Requires ~/.fzf to exist (managed via externals — see TODO/externals.toml).

: <<'__ISH__'
run_when = "onchange"
__ISH__

set -euo pipefail

if [[ ! -e "${HOME}/.fzf" ]]; then
  ish_warning "Cannot find ~/.fzf — skipping fzf setup (externals not yet applied)"
  exit 0
fi

pushd "${HOME}/.fzf" > /dev/null || exit 1
if ! ./install --key-bindings --completion --no-update-rc --no-bash --no-zsh --no-fish; then
  ish_error "Failed to run fzf install"
  popd > /dev/null || true
  exit 1
else
  ish_info "fzf install script executed successfully"
fi
popd > /dev/null || true

ish_info "fzf key-bindings and completion installed"
