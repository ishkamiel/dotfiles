#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="i3 window manager"

PACKAGES=( feh i3 guake compton gdm lxappearance xautolock
network-manager-gnome gnome-keyring gnome-terminal )

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
