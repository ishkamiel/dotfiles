#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

from pathlib import Path
import os
import pytest


def _source_candidates(root: Path) -> list[Path]:
    directories: tuple[Path, Path] = (root / ".chezmoitemplates", root / "scripts")
    source_files: list[Path] = []

    for directory in directories:
        if not directory.exists():
            continue
        source_files.extend(directory.rglob("*.sh"))
        source_files.extend(directory.rglob("*.sh.tmpl"))

    return sorted(source_files)


def _read_firs_line(path: Path) -> str | None:
    try:
        first_line = path.read_text(encoding="utf-8", errors="ignore").splitlines()[0]
    except IndexError:
        return None
    except OSError:
        return None
    return first_line


def _shebang_shell(path: Path) -> str | None:
    first_line: str | None = _read_firs_line(path)
    if first_line is None or not first_line.startswith("#!"):
        return None

    tokens: list[str] = first_line[2:].strip().split()
    if not tokens:
        return None

    interpreter: str = Path(tokens[0]).name
    if interpreter == "env":
        for token in tokens[1:]:
            if token.startswith("-"):
                continue
            interpreter = Path(token).name
            break

    if interpreter in {"bash", "zsh", "sh"}:
        return interpreter

    return None


def _src_files_for_shell(root: Path, shell: str) -> list[Path]:
    return [path for path in _source_candidates(root) if _shebang_shell(path) == shell]


def _src_files_bash(root: Path) -> list[Path]:
    return _src_files_for_shell(root, "bash") + [
        root / "dot_bashrc",
        root / "dot_profile",
    ]


def _src_files_zsh(root: Path) -> list[Path]:
    return _src_files_for_shell(root, "zsh") + [
        root / "dot_zshrc",
        root / "dot_zprofile",
    ]


def _src_files_sh(root: Path) -> list[Path]:
    return _src_files_for_shell(root, "sh")


@pytest.fixture
def src_files_bash(root) -> list[Path]:
    return _src_files_bash(root)


@pytest.fixture
def src_files_zsh(root) -> list[Path]:
    return _src_files_zsh(root)


@pytest.fixture
def src_files_sh(root) -> list[Path]:
    return _src_files_sh(root)


@pytest.fixture
def root() -> Path:
    return Path(os.path.dirname(os.path.abspath(__file__))).parent


def pytest_generate_tests(metafunc) -> None:
    root_path: Path = Path(os.path.dirname(os.path.abspath(__file__))).parent

    if "src_file_bash" in metafunc.fixturenames:
        src_files_bash: list[Path] = _src_files_bash(root_path)
        ids_bash: list[str] = [str(fn.relative_to(root_path)) for fn in src_files_bash]
        metafunc.parametrize("src_file_bash", src_files_bash, ids=ids_bash)

    if "src_file_zsh" in metafunc.fixturenames:
        src_files_zsh: list[Path] = _src_files_zsh(root_path)
        ids_zsh: list[str] = [str(fn.relative_to(root_path)) for fn in src_files_zsh]
        metafunc.parametrize("src_file_zsh", src_files_zsh, ids=ids_zsh)

    if "src_file_sh" in metafunc.fixturenames:
        src_files_sh: list[Path] = _src_files_sh(root_path)
        ids_sh: list[str] = [str(fn.relative_to(root_path)) for fn in src_files_sh]
        metafunc.parametrize("src_file_sh", src_files_sh, ids=ids_sh)
