#!/bin/bash

# leave this empty to disable any asking
ASK=

PACKAGE_DESCRIPTTION="various development stuff"

PACKAGES=(build-essential doxygen libcppunit-dev cmake ninja-build python-dev
exuberant-ctags libsdl2-dev)

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
