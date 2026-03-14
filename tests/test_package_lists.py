#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

# Detect duplicate package names within each packages=(...) array block in
# install scripts.  Template directives (#{{ ... }}) are ignored so that
# conditional blocks don't confuse the parser.

from pathlib import Path


def _extract_package_arrays(content: str) -> list[list[str]]:
    """Return one list of package names per packages=(...) block found."""
    arrays: list[list[str]] = []
    current: list[str] | None = None

    for line in content.splitlines():
        stripped = line.strip()

        # Skip Go template directives embedded as shell comments
        if stripped.startswith("#{{"):
            continue

        if stripped.startswith("packages=("):
            current = []
            # Handle single-line form: packages=(foo bar) — unlikely but safe
            rest = stripped[len("packages=(") :]
            if rest.endswith(")"):
                arrays.append(
                    [
                        tok
                        for tok in rest[:-1].split()
                        if tok and not tok.startswith("#")
                    ]
                )
                current = None
            continue

        if current is not None:
            if stripped == ")":
                arrays.append(current)
                current = None
            elif stripped and not stripped.startswith("#"):
                # Each non-empty, non-comment token on this line is a package name
                current.extend(
                    tok for tok in stripped.split() if tok and not tok.startswith("#")
                )

    return arrays


def test_no_duplicate_packages(install_script_file: Path) -> None:
    content = install_script_file.read_text(encoding="utf-8")
    arrays = _extract_package_arrays(content)

    all_duplicates: list[str] = []
    for packages in arrays:
        seen: set[str] = set()
        for pkg in packages:
            if pkg in seen:
                all_duplicates.append(pkg)
            seen.add(pkg)

    assert (
        not all_duplicates
    ), f"{install_script_file.name}: duplicate package(s) in array: {sorted(set(all_duplicates))}"
