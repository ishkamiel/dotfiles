#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Installs Claude Code via the official curl installer if not already present.

: <<'__ISH__'
tags = ["installClaude"]
run_when = "onchange"
only_on  = ["unixlike"]
__ISH__

set -euo pipefail

if command -v claude &>/dev/null; then
  ish_info "claude already installed: $(claude --version 2>/dev/null || echo 'unknown version')"
  exit 0
fi

if ! command -v curl &>/dev/null; then
  ish_warning "curl not found — cannot install claude"
  exit 0
fi

if ! command -v bash &>/dev/null; then
  ish_warning "bash not found — cannot install claude"
  exit 0
fi

ish_info "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

ish_info "Claude Code installed: $(claude --version 2>/dev/null || echo 'ok')"
