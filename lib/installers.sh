#! /usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2018-2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

[[ ${DOTFILES_LIB_INSTALLERS_SH:=0} == 1 ]] && return 0
DOTFILES_LIB_INSTALLERS_SH=1

. "${ISHLIB}/ishlib.sh"

declare -A apt_install_directives=(
  [bat]=bat
  [cargo]=cargo
  [eza]=eza
  [fd]=fd-find
  [git]=git
  [stow]=stow
)

declare -A cargo_install_directives=(
  [cargo-update]=cargo-update
  [bat]=bat
  [eza]=eza
)

install_apt_pkg() {
  local pkg="$1"
  ish_run -s apt-get install -y "$pkg"
}

install_cargo_pkg() {
  local pkg="$1"
  ish_run cargo install --locked "$pkg"
}

install_apt_cmd_pkg() {
  local cmd="$1"           # Command we need
  local pkg="${2:-$cmd}"   # Package name that defaults to command name

  if command -v "$cmd" &> /dev/null; then
    ish_debug "Skipping, found command $cmd"
    return 0
  fi

  install_apt_pkg "${pkg}"
}

install_cargo_cmd_pkg() {
  local force_install=false

  while getopts ":f" opt; do
    case ${opt} in
      f )
        force_install=true
        ;;
      \? )
        echo "Invalid option: -$OPTARG" >&2
        return 1
        ;;
    esac
  done
  shift $((OPTIND -1))

  local cmd="$1"           # Command we need
  local pkg="${2:-$cmd}"   # Package name that defaults to command name

  # Check if we have $cmd available, unless -f was used to force install
  if [[ "$force_install" != true ]]; then
    # Make sure cargo is in the PATH so we can actually check
    ish_prepend_to_path "${HOME}/.cargo/bin"

    if command -v "$cmd" &> /dev/null; then
      # And we're done since the command was already found
      ish_debug "Skipping install, found command $cmd"
      return 0
    fi
  fi

  install_cargo_pkg "$pkg"
}

install_cmd_somehow() {
  local cmd="$1"           # Command we need
  local pkg="${2:-$cmd}"   # Package name that defaults to command name

  if command -v "$cmd" &> /dev/null; then
    ish_debug "Skipping install, found command $cmd"
    return 0
  fi

  # Try to install with cargo
  if [[ -n "${cargo_install_directives[$cmd]+x}" ]]; then
    ish_debug "Trying to install ${cmd} with cargo"
    if install_cargo_cmd_pkg "$cmd" "${cargo_install_directives[$cmd]}"; then
      return 0
    fi
  fi

  # Try to install with apt
  if [[ -n "${apt_install_directives[$cmd]+x}" ]]; then
    ish_debug "Trying to install ${cmd} with apt"
    if install_apt_cmd_pkg "$cmd" "${apt_install_directives[$cmd]}"; then
      return 0
    fi
  fi

  ish_warn "No install directive for $cmd"
  return 1
}

install_apt_pkg_unless_found() {
  local pkg="$1"

  if dpkg -l | grep -E '^ii\s+'"$pkg"'\s' > /dev/null; then
    ish_debug "Skipping install, found package $pkg"
    return 0
  fi

  install_apt_pkg "$pkg"
}
