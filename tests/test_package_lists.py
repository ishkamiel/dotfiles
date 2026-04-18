# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

# Detect duplicate package names within each package manager across all
# ishconfig/packages*.toml files.

import sys
from pathlib import Path

import pytest

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib

ROOT = Path(__file__).parent.parent
MANAGERS = ["apt", "dnf", "brew", "cargo", "winget"]
PACKAGE_FILES = list(ROOT.glob("ishconfig/packages*.toml"))


@pytest.fixture(scope="session")
def all_packages() -> dict[str, dict]:
    """Merge all package entries from all packages*.toml files.

    Fails fast if the same logical key appears in more than one file, since
    that silently masks whichever copy was read last.
    """
    merged: dict[str, dict] = {}
    origin: dict[str, Path] = {}
    for path in PACKAGE_FILES:
        data = tomllib.loads(path.read_text(encoding="utf-8"))
        for key, entry in data.items():
            if isinstance(entry, dict):
                if key in merged:
                    raise AssertionError(
                        f"duplicate package key '{key}' in {origin[key]} and {path}"
                    )
                merged[key] = entry
                origin[key] = path
    return merged


@pytest.mark.parametrize("manager", MANAGERS)
def test_no_duplicate_package_names(all_packages, manager) -> None:
    names = [entry[manager] for entry in all_packages.values() if manager in entry]
    seen: set[str] = set()
    dupes: set[str] = set()
    for name in names:
        if name in seen:
            dupes.add(name)
        seen.add(name)
    assert not dupes, f"{manager}: duplicate package name(s): {sorted(dupes)}"
