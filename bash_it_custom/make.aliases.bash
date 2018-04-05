#! /bin/bash
#
# make.aliases.bash
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#

if command -v make >/dev/null 2>&1; then
    alias makej="make -j `getconf _NPROCESSORS_ONLN`"
fi
