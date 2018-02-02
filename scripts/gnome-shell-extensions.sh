#!/bin/bash
#
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#

source "${DOTFILES_BASH}/lib/checks.sh"
source "${DOTFILES_BASH}/lib/debug.sh"

# debug_enable

EXT_LIST_FILE=${DOTFILES}/gnome-shell-extensions
SYSTEM_INSTALL_DIR=/usr/share/gnome-shell/extensions

EXT_TOOL=gnome-shell-extension-tool

if ! running_gnome; then
    >&2 echo "Not running gnome-shell, skipping..."
    exit 0;
fi

if ! has_command ${EXT_TOOL}; then
    >&2 echo "Cannot find ${EXT_TOOL}!"
    exit -1;
fi

if [[ ! -e ${EXT_LIST_FILE} ]]; then
    >&2 echo "Cannot find ${EXT_LIST_FILE}"
    exit -1;
fi

while IFS= read -r ext
do
    d_print "Enabling ${ext}"
    ${EXT_TOOL} -e ${ext}
done < "${EXT_LIST_FILE}"

exit 0
