#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Bootstrap vim-plug for vim and neovim, then install all declared plugins.

: <<'__ISH__'
run_when = "onchange"
__ISH__

set -euo pipefail

readonly _FN_VIM="${HOME}/.vim/autoload/plug.vim"
readonly _FN_NEOVIM="${HOME}/.config/nvim/autoload/plug.vim"
readonly _URL_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

if command -v vim >/dev/null 2>&1; then
  if [[ ! -e "${_FN_VIM}" ]]; then
    mkdir -p "$(dirname "${_FN_VIM}")"
    if ! curl -fsSL "${_URL_PLUG}" -o "${_FN_VIM}"; then
      ish_error "Failed to download vim-plug for vim"
      exit 1
    fi
    ish_info "vim-plug downloaded for vim"
  fi
  if [[ -e "${_FN_VIM}" ]]; then
    vim +PlugInstall +qall
    ish_info "vim plugins installed"
  fi
fi

if command -v nvim >/dev/null 2>&1; then
  if [[ ! -e "${_FN_NEOVIM}" ]]; then
    mkdir -p "$(dirname "${_FN_NEOVIM}")"
    if ! curl -fsSL "${_URL_PLUG}" -o "${_FN_NEOVIM}"; then
      ish_error "Failed to download vim-plug for neovim"
      exit 1
    fi
    mkdir -p "${HOME}/.config/nvim/minisnip"
    ish_info "vim-plug downloaded for neovim"
  fi
  if [[ -e "${_FN_NEOVIM}" ]]; then
    nvim +PlugInstall +qall
    ish_info "neovim plugins installed"
  fi
fi
