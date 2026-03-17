#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>

# Tests for the chezmoi Go template layer (package_list.tmpl).
#
# Strategy: parse .chezmoidata.toml in Python to build a reference
# implementation of the package selection logic, then compare its output
# against `chezmoi execute-template` for a range of profiles.  No package
# names are hardcoded — add/remove entries in the TOML and the tests
# automatically adjust.

import subprocess
import tomllib
from pathlib import Path

import pytest


ROOT = Path(__file__).parent.parent

MANAGERS = ["apt", "dnf", "cargo", "winget"]

# All profiles that exercise distinct branches of the selection logic.
PROFILES = [
    pytest.param(dict(machine_type="min"), id="min"),
    pytest.param(dict(machine_type="def"), id="def"),
    pytest.param(dict(machine_type="def", need_build_tools=True), id="def+build"),
    pytest.param(dict(machine_type="def", is_work=True), id="def+work"),
    pytest.param(dict(machine_type="def", is_gaming=True), id="def+gaming"),
    pytest.param(
        dict(
            machine_type="personal", need_build_tools=True, is_work=True, is_gaming=True
        ),
        id="personal+all",
    ),
]


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture(scope="session")
def packages() -> dict:
    with open(ROOT / ".chezmoidata.toml", "rb") as f:
        return tomllib.load(f)["packages"]


# ---------------------------------------------------------------------------
# Reference implementation (mirrors package_list.tmpl logic in Python)
# ---------------------------------------------------------------------------


def _expected(
    packages: dict,
    mgr: str,
    *,
    optional: bool = False,
    gui_only: bool = False,
    gnome_only: bool = False,
    machine_type: str = "def",
    need_build_tools: bool = False,
    is_work: bool = False,
    is_gaming: bool = False,
) -> set[str]:
    """Return the set of package names the template should emit."""
    result: set[str] = set()
    for pkg in packages.values():
        pkg_name = pkg.get(mgr)
        if not pkg_name:
            continue
        if bool(pkg.get("optional")) != optional:
            continue
        if bool(pkg.get("gui-only")) != gui_only:
            continue
        if bool(pkg.get("gnome-only")) != gnome_only:
            continue
        if pkg.get("min"):
            result.add(pkg_name)
        elif machine_type == "min":
            pass  # non-min packages are excluded on min machines
        elif pkg.get("build_tools") and need_build_tools:
            result.add(pkg_name)
        elif pkg.get("work") and is_work:
            result.add(pkg_name)
        elif pkg.get("gaming") and is_gaming:
            result.add(pkg_name)
        elif pkg.get("no_work") and not is_work:
            result.add(pkg_name)
        elif pkg.get("personal") and machine_type == "personal":
            result.add(pkg_name)
        elif not any(
            pkg.get(f) for f in ("build_tools", "work", "gaming", "no_work", "personal")
        ):
            result.add(pkg_name)
    return result


# ---------------------------------------------------------------------------
# Chezmoi template renderer
# ---------------------------------------------------------------------------


def _render(
    mgr: str,
    *,
    optional: bool = False,
    gui_only: bool = False,
    gnome_only: bool = False,
    machine_type: str = "def",
    need_build_tools: bool = False,
    is_work: bool = False,
    is_gaming: bool = False,
) -> set[str]:
    """Render package_list.tmpl via chezmoi and return the package set."""

    def b(v: bool) -> str:
        return "true" if v else "false"

    ctx = (
        f'(dict "packages" .packages'
        f' "machineType" "{machine_type}"'
        f' "needBuildTools" {b(need_build_tools)}'
        f' "isWork" {b(is_work)}'
        f' "isGaming" {b(is_gaming)})'
    )
    tmpl = (
        f'{{{{ template "package_list.tmpl"'
        f' (dict "mgr" "{mgr}" "optional" {b(optional)} "gui_only" {b(gui_only)} "gnome_only" {b(gnome_only)} "ctx" {ctx}) }}}}'
    )
    r = subprocess.run(
        ["chezmoi", "execute-template", tmpl],
        capture_output=True,
        text=True,
        cwd=ROOT,
    )
    assert r.returncode == 0, f"chezmoi error: {r.stderr.strip()}"
    return {line.strip() for line in r.stdout.splitlines() if line.strip()}


# ---------------------------------------------------------------------------
# Data integrity tests  (pure Python, no chezmoi invocation)
# ---------------------------------------------------------------------------


def test_no_duplicate_package_names(packages):
    """No manager should map two different logical packages to the same name."""
    for mgr in MANAGERS:
        names = [pkg[mgr] for pkg in packages.values() if pkg.get(mgr)]
        seen: set[str] = set()
        dupes = {n for n in names if n in seen or seen.add(n)}  # type: ignore[func-returns-value]
        assert not dupes, f"{mgr}: duplicate package names: {dupes}"


def test_optional_and_required_are_disjoint(packages):
    """A package flagged optional=true must not also appear as required."""
    for mgr in MANAGERS:
        for profile_kwargs in (p.values[0] for p in PROFILES):
            req = _expected(packages, mgr, optional=False, **profile_kwargs)
            opt = _expected(packages, mgr, optional=True, **profile_kwargs)
            overlap = req & opt
            assert (
                not overlap
            ), f"{mgr} profile={profile}: packages in both lists: {overlap}"


# ---------------------------------------------------------------------------
# Template output vs. reference implementation
# ---------------------------------------------------------------------------


@pytest.mark.parametrize("mgr", MANAGERS)
@pytest.mark.parametrize("optional", [False, True], ids=["required", "optional"])
@pytest.mark.parametrize("profile", PROFILES)
def test_template_matches_data(packages, mgr, optional, profile):
    """Template output must exactly match the Python reference implementation."""
    expected = _expected(
        packages, mgr, optional=optional, gui_only=False, gnome_only=False, **profile
    )
    actual = _render(
        mgr, optional=optional, gui_only=False, gnome_only=False, **profile
    )
    missing = expected - actual
    extra = actual - expected
    assert not missing and not extra, (
        f"{mgr} optional={optional} {profile}:\n"
        f"  missing from template: {missing}\n"
        f"  extra in template:     {extra}"
    )
