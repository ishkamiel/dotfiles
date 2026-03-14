#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

# Verify that each install_helpers_{manager}.sh defines the three functions
# that __install_packages() dispatches to: {manager}_is_installed,
# {manager}_is_available, and {manager}_install_packages.

import re
from pathlib import Path

REQUIRED_SUFFIXES = ["is_installed", "is_available", "install_packages"]


def _manager_name(helper_file: Path) -> str:
    # install_helpers_snap.sh -> "snap"
    return re.sub(r"^install_helpers_", "", helper_file.stem)


def test_helper_required_functions(install_helper_file: Path) -> None:
    manager = _manager_name(install_helper_file)
    content = install_helper_file.read_text(encoding="utf-8")
    missing = []
    for suffix in REQUIRED_SUFFIXES:
        fn_name = f"{manager}_{suffix}"
        if not re.search(rf"^{re.escape(fn_name)}\s*\(\)", content, re.MULTILINE):
            missing.append(fn_name)
    assert (
        not missing
    ), f"{install_helper_file.name}: missing function(s): {', '.join(f + '()' for f in missing)}"
