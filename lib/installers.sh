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
brew_packages="stow"

apt_pkg_fd="fd-find"

is_os_macos() { [ "$(uname -s)" = "Darwin" ]; }

install_apt_pkg() {
  if [ "${DOTFILES_APT_UPDATE_DONE:-0}" = 0 ]; then
    ish_run -s apt-get update
    DOTFILES_APT_UPDATE_DONE=1
  fi
  ish_run -s apt-get install -y "$1"
}

install_cargo_pkg() {
  ish_run cargo install --locked "$1"
}

install_brew_pkg() {
  if !command -v brew >/dev/null 2>&1; then
    ish_info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    return 0
  fi

  if [ "${DOTFILES_HOMEBREW_UPDATE_DONE:-0}" = 0 ]; then
    ish_run brew update
    DOTFILES_HOMEBREW_UPDATE_DONE=1
  fi
  ish_run brew install "$1" || { ish_fail "Failed to install $1 with brew"; }
}

install_apt_cmd_pkg() {
  cmd="$1"           # Command we need

  if command -v "$cmd" >/dev/null 2>&1; then
    ish_debug "Skipping, found command $cmd"
    return 0
  fi

  eval "pkg_var=\${apt_pkg_${cmd}:-$cmd}"
  install_apt_pkg "${pkg_var:-$cmd}"
}

install_brew_cmd_pkg() {
  cmd="$1"           # Command we need

  if command -v "$cmd" >/dev/null 2>&1; then
    ish_debug "Skipping, found command $cmd"
    return 0
  fi

  eval "pkg_var=\${brew_pkg_${cmd}:-$cmd}"
  install_brew_pkg "${pkg_var:-$cmd}"
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

  eval "pkg_var=\${cargo_pkg_${cmd}:-$cmd}"
  install_cargo_pkg "${pkg_var:-$cmd}"
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
    for p in $brew_packages; do
      if [ "$cmd" = "$p" ]; then
        # MacOS with port
        ish_debug "Trying to install ${cmd} with port"
        if install_brew_cmd_pkg "$cmd"; then
          return 0
        fi
      fi
    done
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
  fi

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
