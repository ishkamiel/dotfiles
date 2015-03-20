#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="i3 window manager"

PACKAGES=( feh i3 xautolock
gnome-keyring 
rxvt-unicode-256color
pcmanfm
yeahconsole
grive
)

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
