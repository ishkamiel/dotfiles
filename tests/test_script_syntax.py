#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

import subprocess
from pathlib import Path


def test_check_bash_n(src_file_bash) -> None:
    subprocess.check_call(["bash", "-n", str(src_file_bash)])


def test_check_zsh_n(src_file_zsh) -> None:
    subprocess.check_call(["zsh", "-n", str(src_file_zsh)])


def test_check_sh_n(src_file_sh) -> None:
    subprocess.check_call(["sh", "-n", str(src_file_sh)])


def _render_template(path: Path) -> str:
    r = subprocess.run(
        ["chezmoi", "execute-template", "--file", str(path)],
        capture_output=True,
        text=True,
        cwd=path.parent,
    )
    assert (
        r.returncode == 0
    ), f"chezmoi execute-template failed for {path.name}:\n{r.stderr.strip()}"
    return r.stdout


def _check_shell_syntax(shell: str, source: str, label: str) -> None:
    r = subprocess.run(
        [shell, "-n"],
        input=source,
        capture_output=True,
        text=True,
    )
    assert (
        r.returncode == 0
    ), f"{shell} -n failed for rendered {label}:\n{r.stderr.strip()}"


def test_check_bash_n_rendered(src_file_bash_tmpl) -> None:
    rendered = _render_template(src_file_bash_tmpl)
    _check_shell_syntax("bash", rendered, src_file_bash_tmpl.name)


def test_check_zsh_n_rendered(src_file_zsh_tmpl) -> None:
    rendered = _render_template(src_file_zsh_tmpl)
    _check_shell_syntax("zsh", rendered, src_file_zsh_tmpl.name)


def test_check_sh_n_rendered(src_file_sh_tmpl) -> None:
    rendered = _render_template(src_file_sh_tmpl)
    _check_shell_syntax("sh", rendered, src_file_sh_tmpl.name)
