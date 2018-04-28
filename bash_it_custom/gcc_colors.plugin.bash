#! /bin/bash
#
# gcc_colors.plugin.bash
# Copyright (C) 2018 ishkamiel <ishkamiel@aoreal>
#
# Distributed under terms of the MIT license.
#

__init_gcc_colors_plugin() {
    if [ -x /usr/bin/dircolors ]; then
        export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    fi
}

__init_gcc_colors_plugin
