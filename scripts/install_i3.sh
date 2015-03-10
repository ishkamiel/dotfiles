#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="i3 window manager"

PACKAGES=( feh i3 guake roxterm compton gdm keychain lxappearance gpicview
xautolock network-manager-gnome )

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
