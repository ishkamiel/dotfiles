# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

from pathlib import Path
import os
import pytest


def _root() -> Path:
    return Path(os.path.dirname(os.path.abspath(__file__))).parent


def _shebang_shell(path: Path) -> str | None:
    try:
        first_line = path.read_text(encoding="utf-8", errors="ignore").splitlines()[0]
    except (IndexError, OSError):
        return None
    if not first_line.startswith("#!"):
        return None
    tokens = first_line[2:].strip().split()
    if not tokens:
        return None
    interpreter = Path(tokens[0]).name
    if interpreter == "env":
        for token in tokens[1:]:
            if token.startswith("-"):
                continue
            interpreter = Path(token).name
            break
    return interpreter if interpreter in {"bash", "zsh", "sh"} else None


def _candidate_shell_files(root: Path) -> list[Path]:
    return (
        list((root / "ishscripts").glob("*.sh"))
        + list((root / "ishinstallers").glob("*.sh"))
        + list((root / "bin").glob("executable_*"))
    )


def _src_files_bash(root: Path) -> list[Path]:
    by_shebang = [p for p in _candidate_shell_files(root) if _shebang_shell(p) == "bash"]
    fixed = [root / "dot_bashrc", root / "dot_profile"]
    return sorted(p for p in fixed + by_shebang if p.exists())


def _src_files_zsh(root: Path) -> list[Path]:
    by_shebang = [p for p in _candidate_shell_files(root) if _shebang_shell(p) == "zsh"]
    fixed = [root / "dot_zshrc", root / "dot_zprofile"]
    return sorted(p for p in fixed + by_shebang if p.exists())


def _ishinstaller_files(root: Path) -> list[Path]:
    return sorted((root / "ishinstallers").glob("*.sh"))


@pytest.fixture
def root() -> Path:
    return _root()


def pytest_generate_tests(metafunc) -> None:
    root_path = _root()

    if "src_file_bash" in metafunc.fixturenames:
        files = _src_files_bash(root_path)
        metafunc.parametrize(
            "src_file_bash",
            files,
            ids=[str(f.relative_to(root_path)) for f in files],
        )

    if "src_file_zsh" in metafunc.fixturenames:
        files = _src_files_zsh(root_path)
        metafunc.parametrize(
            "src_file_zsh",
            files,
            ids=[str(f.relative_to(root_path)) for f in files],
        )

    if "ishinstaller_file" in metafunc.fixturenames:
        files = _ishinstaller_files(root_path)
        metafunc.parametrize(
            "ishinstaller_file",
            files,
            ids=[str(f.relative_to(root_path)) for f in files],
        )
