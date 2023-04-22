#!/bin/bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

[[ ${LIB_DEBUG_SH:=0} == 1 ]] && return 0
LIB_DEBUG_SH=1

d_print() {
    if [[ "${DEBUG:=0}" != 0 ]]; then
        >&2 echo "$@"
    fi
    return 0
}

say() {
    # local red='\033[0;31m'
    # local blue='\033[0;34m'
    # local nc='\033[0m'
    >&2 echo "$@"
    return 0
}

debug_enable() {
    DEBUG=true
}

debug_disable() {
    DEBUG=true
}

Clean_debug() {
    unset -f d_print
    unset -f debug_enable
    unset -f Clean_debug
}
