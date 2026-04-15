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

if ! command -v curl >/dev/null 2>&1; then
  ish_critical "curl is required to download vim-plug"
fi

if command -v vim >/dev/null 2>&1; then
  if [[ ! -e "${_FN_VIM}" ]]; then
    _folder="$(dirname "${_FN_VIM}")"
    ish_info "Creating ${_folder}"
    mkdir -p "${_folder}"
    if ! curl -fsSL "${_URL_PLUG}" -o "${_FN_VIM}"; then
      ish_critical "Failed to download vim-plug for vim"
    fi
    ish_info "vim-plug downloaded for vim"
  fi
  if [[ -e "${_FN_VIM}" ]]; then
    ish_info "Trying to install plugins..."
    if ! vim -Es -u "${HOME}/.vimrc" +PlugInstall +qall! </dev/null; then
      ish_warning "vim +PlugInstall returned non-zero (plugins may still be installed); continuing"
    fi
    ish_info "vim plugins installed"
  fi
else
  ish_info "No vim found"
fi

if command -v nvim >/dev/null 2>&1; then
  if [[ ! -e "${_FN_NEOVIM}" ]]; then
    mkdir -p "$(dirname "${_FN_NEOVIM}")"
    if ! curl -fsSL "${_URL_PLUG}" -o "${_FN_NEOVIM}"; then
      ish_critical "Failed to download vim-plug for neovim"
    fi
    mkdir -p "${HOME}/.config/nvim/minisnip"
    ish_info "vim-plug downloaded for neovim"
  fi
  if [[ -e "${_FN_NEOVIM}" ]]; then
    if ! nvim --headless +PlugInstall +qall! </dev/null; then
      ish_warning "nvim +PlugInstall returned non-zero (plugins may still be installed); continuing"
    fi
    ish_info "neovim plugins installed"
  fi
else
  ish_info "No nvim found"
fi

exit 0
