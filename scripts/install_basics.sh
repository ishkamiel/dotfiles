#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="i3 window manager"

PACKAGES=(vim-nox git imagemagick)

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
