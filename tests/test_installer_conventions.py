# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

# Verify that each ishinstaller script contains a valid __ISH__ metadata
# heredoc parseable as TOML.

import re
import sys
from pathlib import Path

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib


_ISH_BLOCK_RE = re.compile(
    r":\s*<<'__ISH__'\n(.*?)\n__ISH__", re.DOTALL
)


def _extract_ish_metadata(path: Path) -> str | None:
    content = path.read_text(encoding="utf-8")
    m = _ISH_BLOCK_RE.search(content)
    return m.group(1) if m else None


def test_has_ish_metadata_block(ishinstaller_file: Path) -> None:
    block = _extract_ish_metadata(ishinstaller_file)
    assert block is not None, f"{ishinstaller_file.name}: missing __ISH__ metadata block"


def test_ish_metadata_is_valid_toml(ishinstaller_file: Path) -> None:
    block = _extract_ish_metadata(ishinstaller_file)
    if block is None:
        return  # caught by test_has_ish_metadata_block
    try:
        tomllib.loads(block)
    except Exception as exc:
        raise AssertionError(
            f"{ishinstaller_file.name}: __ISH__ block is not valid TOML: {exc}"
        ) from exc
