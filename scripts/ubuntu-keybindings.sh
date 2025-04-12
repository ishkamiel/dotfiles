#! /usr/bin/env bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

set -e
DOTFILES=${DOTFILES:-"${HOME}/.dotfiles"}
# shellcheck source=../lib/checks.sh
. "${DOTFILES}/lib/checks.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

SUMFILE="${DOTFILES}/.keybindings.md5"
KEYFILE="${DOTFILES}/ubuntu_keybindings"
PYSCRIPT="${DOTFILES}/lib/keybindings.pl"

if ! running_ubuntu; then
    say "skipped, not on ubuntu\n"
    exit 0
fi

if ! running_gnome; then
    say "skipped, not running gnome\n"
    exit 0
fi

if ! md5sum --check --quiet "${SUMFILE}" > /dev/null 2>&1; then
    echo "applying"
    "${PYSCRIPT}" -i "${KEYFILE}"
    md5sum "${KEYFILE}" > "${SUMFILE}"
else
    echo "Already applied"
fi

