#!/bin/bash
#
# checkLocalSettings.sh
# Copyright (C) 2018 ishkamiel <ishkamiel@aoreal>
#
# Distributed under terms of the MIT license.
#

if [[ ! -e ~/.vimrc_local ]]; then
	cat <<EOF > ~/.vimrc_local
" Theses values are use for instance by vim-template.
" let g:email = 'some@email'
" let g:username = 'Someone'
EOF
fi
