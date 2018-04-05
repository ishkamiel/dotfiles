#! /bin/bash
#
# ag.aliases.bash
# Copyright (C) 2018 Hans Liljestrand <liljestrandh@gmail.com>
#
# Distributed under terms of the MIT license.

if command -v ag >/dev/null 2>&1; then
	alias ag='ag --pager="less -MIRFX" --ignore cscope.out'
	alias kag='ag --pager="less -MIRFX" --ignore-dir Documentation --ignore-dir tools --ignore-dir scripts'
	alias gag='ag --pager="less -MIRFX" --ignore-dir testsuite --ignore-dir doc --ignore "ChangeLog*"'
fi
