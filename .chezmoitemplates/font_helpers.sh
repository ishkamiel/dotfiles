#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Shared font-resolution helpers.  Include via:
#   #{{ template "font_helpers.sh" . }}

readonly monospace_fonts=(
    "FiraCode Nerd Font Mono,FiraCode Nerd Font Mono Ret"
    "FiraCode Nerd Font Mono"
    "Ubuntu Mono"
    "Courier"
)

# Usage: __find_first_available_font "Font One" "Font Two" ...
# Prints the first argument that matches an available monospace font,
# or the first available monospace font if none match. Prints nothing on failure.
__find_first_available_font() {
  local available
  available=$(fc-list :spacing=mono family 2>/dev/null \
    | sed 's/,.*//;s/:.*//' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
    | sort -u)

  for pref in "$@"; do
    if echo "$available" | grep -qi "^${pref}$"; then
      echo "$pref"
      return
    fi
  done

  local first
  first=$(echo "$available" | head -1)
  [[ -n "$first" ]] && echo "$first"
}
