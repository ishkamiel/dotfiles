#! /usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

set -euo pipefail

# shellcheck source=../lib/downloadFile.sh
. "${DOTFILES}/lib/downloadFile.sh"
# shellcheck source=../lib/debug.sh
. "${DOTFILES}/lib/debug.sh"

if command -v go >/dev/null 2>&1; then
  pushd "${DOTFILES}/external/fzf"
  make install
  popd
else
  echo "!!! Cannot find go, skipping fzf install"
fi
