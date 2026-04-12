# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

import subprocess


def test_shellcheck_bash(src_file_bash) -> None:
    subprocess.check_call(["shellcheck", "-s", "bash", "-x", "--source-path=SCRIPTDIR", str(src_file_bash)])


def test_shellcheck_zsh(src_file_zsh) -> None:
    # shellcheck has no zsh dialect; bash is the closest match
    subprocess.check_call(["shellcheck", "-s", "bash", "-x", "--source-path=SCRIPTDIR", str(src_file_zsh)])
