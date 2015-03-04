#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="i3 window manager"

PACKAGES=( feh i3 yeahconsole roxterm compton lightdm-gtk-greeter keychain lxappearance gpicview
lightdm xautolock wicd-gtk )

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
