#!/usr/bin/env zsh
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Recompile zsh files for faster startup.

: <<'__ISH__'
run_when = "onchange"

[packages]
bat  = {apt = "bat",  dnf = "bat",  optional = true}
tldr = {apt = "tldr", dnf = "tldr", optional = true}
__ISH__

set -euo pipefail

__zcompile_if_exists() {
  local _f="$1"
  if [[ -e "${_f}" ]]; then
    zrecompile -p -q "${_f}"
  fi
}

__zcompile_all() {
  if ! command -v zcompile >/dev/null 2>&1; then
    ish_warn "zcompile not found; skipping zsh compilation"
    return 0
  fi

  autoload -U zrecompile

  __zcompile_if_exists "${HOME}/.oh-my-zsh/oh-my-zsh.sh"
  __zcompile_if_exists "${HOME}/.zprofile"
  __zcompile_if_exists "${HOME}/.zshrc"
  __zcompile_if_exists "${HOME}/.zcompdump"

  if [[ -e "${HOME}/.oh-my-zsh" ]]; then
    for _f in "${HOME}"/.oh-my-zsh/**/*.zsh; do
      zrecompile -p -q "${_f}"
    done
  fi

  ish_info "zsh files recompiled"
}

__zcompile_all
