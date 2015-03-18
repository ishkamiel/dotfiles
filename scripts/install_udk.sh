#!/bin/bash

# leave this empty to disable any asking
ASK=
PACKAGE_DESCRIPTTION="mono stuff for Unreal Engine"

PACKAGES=( mono-gmcs mono-xbuild mono-dmcs libmono-corlib4.0-cil
libmono-system-data-datasetextensions4.0-cil
libmono-system-web-extensions4.0-cil libmono-system-management4.0-cil
libmono-system-xml-linq4.0-cil cmake dos2unix clang-3.5 xdg-user-dirs)

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/lib/install_packages.sh
