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
" let g:email = 'some@emailä
" let g:username = 'Someone'
EOF
fi

if [[ ! -e ~/.bashrc_local ]]; then
	cat <<EOF > ~/.bashrc_local
# Control whether we should use tmux locally, or at all.
#ISHDOT_TMUX_ENABLE=1
#ISHDOT_TMUX_ALWAYS=1

# Uncomment to hide username@host when UID is for \${DEFAULT_USER}.
#export DEFAULT_USER=${USER}
EOF
fi

if [[ ! -e /~/.profile_local ]]; then
	cat <<EOF > ~/.profile_local
# Add "global" settings here, this will for login shells, and also on
# gnome (and maybe other) logins.

# Uncomment to try loading the Intel SGX SDK from the default location
#[[ -e /opt/intel/sgxsdk/environment ]] && . /opt/intel/sgxsdk/environment
EOF
fi
