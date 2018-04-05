#! /bin/bash
#
# exa.aliases.bash
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.
#

command -v exa >/dev/null 2>&1 && alias ls="exa --time-style=iso --git"
