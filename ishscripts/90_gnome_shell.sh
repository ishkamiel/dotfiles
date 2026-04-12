#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# GNOME Shell configuration: dconf settings, gsettings, and keyboard shortcuts.

: <<'__ISH__'
tags = ["isGnome"]
run_when = "onchange"

[packages]
ulauncher = {apt = "ulauncher", dnf = "ulauncher", optional = true}
__ISH__

set -euo pipefail

__do_dconf() {
  if ! command -v dconf >/dev/null 2>&1; then
    ish_warn "dconf not available; skipping dconf settings"
    return 0
  fi
  dconf write /org/gnome/desktop/background/show-desktop-icons true
  dconf write /org/gnome/mutter/dynamic-workspaces false
  dconf write /org/gnome/desktop/wm/preferences/num-workspaces 4
  dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false
  dconf write /org/gnome/shell/extensions/dash-to-dock/isolate-workspaces true
  dconf write /org/gnome/shell/extensions/tiling-assistant/tiling-popup-all-workspace false
  dconf write /org/gnome/desktop/sound/event-sounds false
  ish_info "dconf settings applied"
}

__do_gsettings() {
  if ! command -v gsettings >/dev/null 2>&1; then
    ish_warn "gsettings not available; skipping gsettings"
    return 0
  fi
  gsettings set org.gnome.desktop.interface enable-animations false
  gsettings set org.gnome.desktop.interface enable-hot-corners false
  gsettings set org.gnome.desktop.calendar show-weekdate true
  gsettings set org.gnome.desktop.input-sources xkb-options '["caps:escape"]'
  gsettings set org.gnome.desktop.interface clock-format '24h'
  gsettings set org.gnome.shell.app-switcher current-workspace-only true
  ish_info "gsettings applied"
}

__keyboard_shortcuts() {
  # shellcheck disable=SC2154  # __ish_scripts_dir is substituted by the @ish preprocessor
  local _scripts_dir="${__ish_scripts_dir}"
  local _keys="${_scripts_dir}/data/gnome_keybindings"
  local _script="${_scripts_dir}/lib/keybindings.pl"

  if [[ ! -f "${_keys}" ]]; then
    ish_warn "gnome_keybindings data file not found: ${_keys}"
    return 0
  fi
  if [[ ! -f "${_script}" ]]; then
    ish_warn "keybindings.pl not found: ${_script}"
    return 0
  fi

  if ! command -v gsettings >/dev/null 2>&1; then
    ish_warn "gsettings not available; skipping keyboard shortcuts"
    return 0
  fi

  "${_script}" -i "${_keys}"
  ish_info "GNOME keyboard shortcuts applied"
}

__do_dconf
__do_gsettings
__keyboard_shortcuts
