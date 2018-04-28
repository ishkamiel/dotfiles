#! /bin/bash
#
# exa.aliases.bash
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#

__init_exa_plugin() {
    local cargo_bin_path="${HOME}/.cargo/bin"
    local exa_args="--time-style=iso --git"

    has_exa() {
        command -v exa >/dev/null 2>&1 && return 0
        if [[ -e $cargo_bin_path ]]; then
            pathmunge "${cargo_bin_path}"
            command -v exa >/dev/null 2>&1 && return 0
        fi
        return 1
    }

    if ! has_exa; then
        echo "Cannot find exa, is it installed?"
        echo "    Looked in \$PATH and ${cargo_bin_path}"
    else
        alias ls="exa ${exa_args}"
        alias la="exa ${exa_args} -a"
        alias ll="exa ${exa_args} -al"
        alias sl="exa ${exa_args}"
        alias tree="exa ${exa_args} -T"
        unalias l1
        unalias l
    fi
}

__init_exa_plugin
