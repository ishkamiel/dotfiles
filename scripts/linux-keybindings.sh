#! /usr/bin/env bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

set -e

SUMFILE="${DOTFILES}/.keybindings.md5"
KEYFILE="${DOTFILES}/keybindings"
PYSCRIPT="${DOTFILES}/lib/keybindings.pl"

# shellcheck source=../lib/checks.sh
. "${DOTFILES}/lib/checks.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

if ! running_gnome; then
    printf "Not running on gnome, skipping keybinginds\n"
    exit 0
fi

if ! md5sum --check --quiet "${SUMFILE}" > /dev/null 2>&1; then
    echo "applying"
    "${PYSCRIPT}" -i "${KEYFILE}"
    md5sum "${KEYFILE}" > "${SUMFILE}"
else
    echo "Already applied"
fi

