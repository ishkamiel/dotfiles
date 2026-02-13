#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

import subprocess


def test_check_bash_n(src_file_bash) -> None:
    subprocess.check_call(["bash", "-n", str(src_file_bash)])


def test_check_zsh_n(src_file_zsh) -> None:
    subprocess.check_call(["zsh", "-n", str(src_file_zsh)])


def test_check_sh_n(src_file_sh) -> None:
    subprocess.check_call(["sh", "-n", str(src_file_sh)])
