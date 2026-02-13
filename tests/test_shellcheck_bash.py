#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

import os
import subprocess
from pathlib import Path


def test_shellcheck_bash_n(src_file_bash) -> None:
    subprocess.check_call(["shellcheck", "-s", "bash", "-x", str(src_file_bash)])


def test_shellcheck_zsh_n(src_file_zsh) -> None:
    subprocess.check_call(["shellcheck", "-s", "bash", "-x", str(src_file_zsh)])


def test_shellcheck_sh_n(src_file_sh) -> None:
    subprocess.check_call(["shellcheck", "-s", "sh", "-x", str(src_file_sh)])
