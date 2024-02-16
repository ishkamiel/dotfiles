#! /usr/bin/env bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

readonly SCRIPT_NAME="$( basename -- "${BASH_SOURCE[0]}" )"

set -e
DOTFILES=${DOTFILES:-"${HOME}/.dotfiles"}
# shellcheck source=../lib/checks.sh
. "${DOTFILES}/lib/checks.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

# Load packages lists
# shellcheck source=../lib/apt_packages
. "${DOTFILES}/misc/apt_packages"

err=0
NEED_INSTALL=()
MISSING_COMMANDS=()

find_NEED_INSTALL() {
    if ! running_ubuntu; then
      say "=== skipped APT packages checks, not on Ubuntu\n"
      return 0
    fi

    for pkg in "${APT_PACKAGES[@]}"; do
      if is_package_installed ${pkg}; then
        d_print "${SCRIPT_NAME}:${FUNCNAME[0]}: ${pkg} is installed"
      else
        d_print "${SCRIPT_NAME}:${FUNCNAME[0]}: ${pkg} is NOT installed"
        NEED_INSTALL+=( "${pkg}" )
      fi
    done
}

check_COMMANDS() {
  for cmd in "${SHELL_COMMANDS[@]}"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      d_print "${SCRIPT_NAME}:${FUNCNAME[0]}: ${cmd} found"
    else
      d_print "${SCRIPT_NAME}:${FUNCNAME[0]}: ${cmd} NOT found"
      MISSING_COMMANDS+=( "${cmd}" )
    fi
  done
}

find_NEED_INSTALL
check_COMMANDS

if (( ${#NEED_INSTALL[@]} != 0 )); then
  echo -e "=== Missing packages:\n\t${NEED_INSTALL[*]}"
  (( err = err + 1 ))
fi
if (( ${#MISSING_COMMANDS[@]} != 0 )); then
  echo -e "=== Cannot find commands:\n\t${MISSING_COMMANDS[*]}"
 (( err = err + 1 ))
fi

if (( err == 0 )); then
  echo "=== Found no missing pakcages or commands"
fi

exit 0
