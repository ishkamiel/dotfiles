#!/bin/bash
#
# Author: Hans Liljestrand <liljestrandh@gmail.com>
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

LIB_DEBUG_SH=1

d_print() {
    if [[ -n "${DEBUG}" ]]; then
        >&2 echo $@
    fi
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
