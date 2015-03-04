#!/bin/bash

# leave this empty to disable any asking
ASK=

PACKAGE_DESCRIPTTION="libraries for OGRE and CEGUI"

PACKAGES=(zziplib-bin nvidia-cg-toolkit nvidia-cg-dev libfreeimage-dev
libboost-all-dev zlib1g-dev libois-dev libpoco-dev libtbb-dev libfreetype6-dev
libzip-dev libtinyxml-dev libzzip-dev libgles2-mesa-dev libglfw3-dev libglm-dev
libsilly-dev pyside-tools libfribidi-dev libglfw2 libminizip-dev python-pyside
python-opengl libglew-dev libtolua++5.1-dev libxerces-c-dev libdirectfb-dev)

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
