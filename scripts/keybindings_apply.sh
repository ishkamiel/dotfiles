#!/bin/bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

SUMFILE=".keybindings.md5"
KEYFILE="keybindings"

if ! md5sum --check --quiet ${SUMFILE} > /dev/null 2>&1; then
    echo "applying"
    scripts/keybindings.pl -i ${KEYFILE}
    md5sum ${KEYFILE} > ${SUMFILE}
else
    echo "Already applied"
fi

