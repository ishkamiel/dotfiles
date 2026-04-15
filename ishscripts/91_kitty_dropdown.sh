#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Install and configure the Quake Terminal GNOME Shell extension,
# which provides a Wayland-native drop-down Kitty terminal toggled via Alt+§.

: <<'__ISH__'
tags = ["isGnome"]
run_when = "onchange"
__ISH__

set -euo pipefail

readonly QUAKE_UUID='quake-terminal@diegodario88.github.io'
readonly QUAKE_SCHEMA='org.gnome.shell.extensions.quake-terminal'
readonly QUAKE_EXT_DIR="${HOME}/.local/share/gnome-shell/extensions/${QUAKE_UUID}"

__qgs() {
  gsettings --schemadir "${QUAKE_EXT_DIR}/schemas" set "${QUAKE_SCHEMA}" "$@"
}

__cleanup_legacy_keybindings() {
  local _media_keys='org.gnome.settings-daemon.plugins.media-keys'
  local _current_list
  _current_list=$(gsettings get "${_media_keys}" custom-keybindings)

  for _legacy_path in \
    '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake/' \
    '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/kitty-dropdown/'
  do
    if [[ "${_current_list}" == *"${_legacy_path}"* ]]; then
      _current_list=$(printf '%s' "${_current_list}" \
        | sed "s|, '${_legacy_path}'||; s|'${_legacy_path}', ||; s|'${_legacy_path}'||")
      ish_info "Removed legacy keybinding: ${_legacy_path}"
    fi
  done

  gsettings set "${_media_keys}" custom-keybindings "${_current_list}"
}

__install_quake_terminal() {
  if gnome-extensions list 2>/dev/null | grep -qxF "${QUAKE_UUID}"; then
    ish_info "Quake Terminal already installed"
    return 0
  fi

  local _shell_ver
  _shell_ver=$(gnome-shell --version 2>/dev/null | awk '{print $3}' | cut -d. -f1)
  if [[ -z "${_shell_ver}" ]]; then
    ish_error "Cannot determine GNOME Shell version; skipping Quake Terminal install"
    return 1
  fi

  local _zip_file
  _zip_file=$(mktemp --suffix=.zip)
  # shellcheck disable=SC2064
  trap "rm -f '${_zip_file}'" RETURN

  if ! curl -sSL \
    "https://extensions.gnome.org/download-extension/${QUAKE_UUID}.shell-extension.zip?shell_version=${_shell_ver}" \
    -o "${_zip_file}"; then
    ish_error "Failed to download Quake Terminal extension"
    return 1
  fi

  gnome-extensions install --force "${_zip_file}"
  ish_info "Installed Quake Terminal extension (GNOME Shell ${_shell_ver})"
}

__configure_quake_terminal() {
  if [[ ! -d "${QUAKE_EXT_DIR}/schemas" ]]; then
    ish_error "Quake Terminal schema dir not found: ${QUAKE_EXT_DIR}/schemas"
    return 1
  fi

  __qgs terminal-id      'kitty.desktop'
  __qgs terminal-shortcut "['<Alt>section']"
  __qgs vertical-size    100
  __qgs always-on-top    true
  ish_info "Configured Quake Terminal"
}

__enable_quake_terminal() {
  gnome-extensions enable "${QUAKE_UUID}" 2>/dev/null || true
}

if ! command -v gsettings >/dev/null 2>&1; then
  ish_warning "gsettings not available; skipping Quake Terminal setup"
  exit 0
fi

__cleanup_legacy_keybindings
__install_quake_terminal
__configure_quake_terminal
__enable_quake_terminal
