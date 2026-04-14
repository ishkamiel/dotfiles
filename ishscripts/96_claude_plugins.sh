#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Checks that all marketplace plugins declared in ~/.claude/settings.json
# are installed. Prints /plugin install instructions for any that are missing.
# Cannot install them automatically — Claude Code has no shell-level install CLI.

: <<'__ISH__'
run_when = "onchange"
only_on  = ["unixlike"]
__ISH__

set -euo pipefail

SETTINGS="${HOME}/.claude/settings.json"
INSTALLED="${HOME}/.claude/plugins/installed_plugins.json"

if [[ ! -f "${SETTINGS}" ]]; then
  ish_warn "${HOME}/.claude/settings.json not found — skipping claude plugin check"
  exit 0
fi

if ! command -v jq &>/dev/null; then
  ish_warn "jq not found — skipping claude plugin check"
  exit 0
fi

missing=()

while IFS= read -r plugin_key; do
  if [[ ! -f "${INSTALLED}" ]] || ! jq -e --arg k "${plugin_key}" '.plugins[$k] // empty' "${INSTALLED}" &>/dev/null; then
    missing+=("${plugin_key}")
  fi
done < <(jq -r '.enabledPlugins // {} | keys[]' "${SETTINGS}")

if [[ ${#missing[@]} -eq 0 ]]; then
  ish_info "claude plugins: all enabled plugins are installed"
else
  ish_warn "claude plugins: the following plugins are enabled in settings.json but not installed:"
  for p in "${missing[@]}"; do
    ish_warn "  Run inside Claude Code: /plugin install ${p}"
  done
fi
