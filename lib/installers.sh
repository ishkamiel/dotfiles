#! /usr/bin/sh
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2018-2025 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

[ "${DOTFILES_LIB_INSTALLERS_SH:=0}" = 1 ] && exit 0
DOTFILES_LIB_INSTALLERS_SH=1

. "${ISHLIB}/ishlib.sh"

DOTFILES_APT_UPDATE_DONE=0

apt_packages="bat cargo eza fd git stow"
cargo_packages="cargo-update bat eza"
port_packages=""

apt_pkg_fd="fd-find"

is_os_macos() { [[ "$(uname -s)" == "Darwin" ]] }

install_apt_pkg() {
  pkg="$1"

  eval "pkg_var=\${apt_pkg_${pkg}:-$pkg}"
  pkg="$pkg_var"

  if [ "$DOTFILES_APT_UPDATE_DONE" = 0 ]; then
    ish_run -s apt-get update
    DOTFILES_APT_UPDATE_DONE=1
  fi
  ish_run -s apt-get install -y "$pkg"
}

install_cargo_pkg() {
  pkg="$1"

  eval "pkg_var=\${cargo_pkg_${pkg}:-$pkg}"
  pkg="$pkg_var"

  ish_run cargo install --locked "$pkg"
}

install_apt_cmd_pkg() {
  cmd="$1"           # Command we need
  eval "pkg_var=\${apt_pkg_${pkg}:-$pkg}"
  pkg="${pkg_var:-$cmd}"

  if command -v "$cmd" >/dev/null 2>&1; then
    ish_debug "Skipping, found command $cmd"
    return 0
  fi

  install_apt_pkg "$pkg"
}

install_port_cmd_pkg() {
  cmd="$1"           # Command we need
  eval "pkg_var=\${port_pkg_${pkg}:-$pkg}"
  pkg="${pkg_var:-$cmd}"

  if command -v "$cmd" >/dev/null 2>&1; then
    ish_debug "Skipping, found command $cmd"
    return 0
  fi

  install_port_pkg "pkg"
}

install_cargo_cmd_pkg() {
  force_install=false

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

  cmd="$1"
  eval "pkg_var=\${cargo_pkg_${pkg}:-$pkg}"
  pkg="${pkg_var:-$cmd}"

  # Check if we have $cmd available, unless -f was used to force install
  if [ "$force_install" != true ]; then
    # Make sure cargo is in the PATH so we can actually check
    ish_prepend_to_path "${HOME}/.cargo/bin"

    if command -v "$cmd" >/dev/null 2>&1; then
      # And we're done since the command was already found
      ish_debug "Skipping install, found command $cmd"
      return 0
    fi
  fi

  install_cargo_pkg "$pkg"
}

install_cmd_somehow() {
  cmd="$1"           # Command we need
  pkg="${2:-$cmd}"   # Package name that defaults to command name

  if command -v "$cmd" >/dev/null 2>&1; then
    ish_debug "Skipping install, found command $cmd"
    return 0
  fi

  # Try to install with cargo
  for p in $cargo_packages; do
    if [ "$cmd" = "$p" ]; then
      ish_debug "Trying to install ${cmd} with cargo"
      if install_cargo_cmd_pkg "$cmd"; then
        return 0
      fi
    fi
  done


  if is_os_macos; then
    # MacOS
    for p in $port_packages; do
      if [ "$cmd" = "$directive" ]; then
      # MacOS with port
      ish_debug "Trying to install ${cmd} with port"
      if install_port_cmd_pkg "$cmd"; then
        return 0
      fi
    fi
  else
    # Linux with apt
    for p in $apt_packages; do
      if [ "$cmd" = "$p" ]; then
        ish_debug "Trying to install ${cmd} with apt"
        if install_apt_cmd_pkg "$cmd"; then
          return 0
        fi
      fi
  done

  ish_warn "No install directive for $cmd"
  return 1
}

install_apt_pkg_unless_found() {
  pkg="$1"

  if dpkg -l | grep -E '^ii\s+'"$pkg"'\s' >/dev/null; then
    ish_debug "Skipping install, found package $pkg"
    return 0
  fi

  install_apt_pkg "$pkg"
}
