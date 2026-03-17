# CLAUDE.md

This is a [chezmoi](https://www.chezmoi.io/) dotfiles repository for Hans Liljestrand, targeting Linux (Ubuntu, Fedora), macOS, and Windows.

## Repository Structure

```
.chezmoi.toml.tmpl       # chezmoi config template (machine type, user data)
.chezmoiignore           # OS-conditional ignore rules
.chezmoiexternal.toml    # External git repos and archives (fzf, oh-my-zsh, pyenv, fnm)
.chezmoiscripts/
  unix-like/             # Bash install/config scripts for Linux & macOS
  windows/               # PowerShell install/config scripts for Windows
.chezmoitemplates/       # Shared template snippets included by scripts
dot_config/              # ~/.config/* (nvim, git, starship, direnv, powershell)
dot_local/               # ~/.local/* (bins, fonts)
dot_*/                   # Other dotfiles (zshrc, vimrc, tmux.conf, etc.)
tests/                   # pytest tests for script syntax and shellcheck
run_pytest.sh            # Helper script to run pytest, passes args as-is to pytest
```

## Chezmoi File Naming Conventions

- `dot_foo` → `~/.foo`
- `executable_foo` → executable file `foo`
- `foo.tmpl` → Go template file, processed by chezmoi
- `run_*.sh.tmpl` → script run every apply
- `run_once_*.sh.tmpl` → script run once
- `run_onchange_*.sh.tmpl` → script run when content changes (hash-based)
- Scripts are numbered for ordering: `run_0_init`, `run_onchange_1_install_apt`, `run_z_finalize`

## Template Variables (`.chezmoi.toml.tmpl`)

| Variable | Values | Description |
|---|---|---|
| `.machineType` | `min`, `def`, `personal` | Minimum, default, or personal workstation |
| `.isWork` | bool | Work machine (affects which apps are installed) |
| `.needBuildTools` | bool | Install compilers, CMake, LLVM, Rust, etc. |
| `.chezmoi.os` | `linux`, `darwin`, `windows` | Target OS |
| `.chezmoi.osRelease.id` | `ubuntu`, `fedora`, etc. | Linux distro |
| `.chezmoi.arch` | `amd64`, `arm64` | CPU architecture |

## Platform-Specific Scripts

- `.chezmoiscripts/unix-like/` — bash scripts for Linux/macOS; excluded on Windows via `.chezmoiignore`
- `.chezmoiscripts/windows/` — PowerShell scripts; excluded on non-Windows
- OS-specific package scripts (`install_apt`, `install_dnf`, `install_brew`, `install_winget`) are each excluded on non-matching OSes

## Template Helpers

Scripts include shared helpers via `{{ template "..." . }}`:

- `install_helpers.sh` — `log_error`, `verbose_echo`, `__install_packages`, `downloadFile`, `running_gui`, `running_gnome`
- `install_helpers_apt.sh` — `apt_install`, `apt_add_ppa`, `apt_add_repo`, `apt_add_key`
- `install_helpers_dnf.sh`, `install_helpers_brew.sh`, `install_helpers_snap.sh` — per-manager install functions
- `package_list.tmpl` — generates package names for a manager, filtered by profile flags (see below)
- `ppa_list.tmpl` — generates `apt_add_ppa` calls for packages with `ubuntu-ppa` field
- `windows/logger.ps1`, `windows/install_helpers.ps1`, `windows/json_helpers.ps1`

## Error Handling Pattern

Scripts log errors to `~/.chezmoi_error.log` using `log_error()` from `install_helpers.sh`. The `run_z_finalize.sh.tmpl` script reports accumulated errors at the end of an apply.

## File Headers

All shell/Python/template files must have SPDX headers — enforced by pre-commit:

```bash
# SPDX-License-Identifier: MIT
# Copyright (C) <year> Hans Liljestrand <hans@liljestrand.dev>
```

For chezmoi template files (`.tmpl`), the header uses Go comment style:
```
{{- /*
 SPDX-License-Identifier: MIT
 Copyright (C) <year> Hans Liljestrand <hans@liljestrand.dev>
*/ -}}
```

## Testing

```bash
pytest                          # Run all tests
pytest tests/test_shellcheck_bash.py   # Shellcheck on bash scripts
pytest tests/test_script_syntax.py    # Syntax checks
```

Tests run via pre-commit on every commit. The pre-commit config also enforces: trailing whitespace, JSON/YAML/TOML validity, no private keys, and license header insertion.

## Pre-commit

```bash
pre-commit run --all-files      # Run all hooks manually
```

The project uses direnv (`.envrc`) and a `.python-version` file; activate the virtualenv before running tests.

## Package Data (`.chezmoidata.toml`)

All packages are declared in `.chezmoidata.toml` under `[packages.<key>]`. Each entry can have:

| Field | Description |
|---|---|
| `apt`, `dnf`, `brew`, `cargo`, `winget` | Package name for that manager (omit if unavailable) |
| `ubuntu-ppa` | PPA to add before installing (apt only, e.g. `"ppa:foo/bar"`) |
| `min = true` | Install on all machine types including `min` |
| `build_tools = true` | Only when `needBuildTools` is set |
| `work = true` | Only when `isWork` is set |
| `no_work = true` | Only when `isWork` is NOT set |
| `gaming = true` | Only when `isGaming` is set |
| `personal = true` | Only when `machineType == "personal"` |
| `gui-only = true` | Runtime-checked: only installed when a GUI/display is detected |
| `gnome-only = true` | Runtime-checked: only installed when GNOME is the desktop |
| `optional = true` | Suppress install errors if unavailable |

Packages without any profile flag are installed on all non-`min` machines. Machine type filtering is handled entirely by `package_list.tmpl` — install scripts do not need `#{{ if ne .machineType "min" }}` wrappers.

### Install script structure (apt and dnf)

```
PPAs + required packages (non-GUI)
optional packages (non-GUI)
if running_gui; then   ← PPAs + required + optional gui-only packages
if running_gnome; then ← PPAs + required + optional gnome-only packages
```

`package_list.tmpl` parameters: `mgr`, `optional`, `gui_only`, `gnome_only`, `ctx` (and `quote` for PowerShell).
`ppa_list.tmpl` parameters: `gui_only`, `gnome_only`, `ctx`.

## `#{{ }}` Template Directive Pattern

In `.tmpl` bash scripts, Go template actions are written as `#{{ action }}` so the source file is valid bash (the `#` makes the line a comment). Key behaviour:

- `#{{ range/if/end ... }}` — the `#` is **literal output**; the action controls flow but produces no text itself
- `#{{ template "foo.tmpl" . }}` — outputs `#\n<template content>`; since template content starts with `\n`, the `#` lands on its own blank comment line and the content follows on subsequent lines — this is how `package_list.tmpl` and `ppa_list.tmpl` work
- **Never** use `#{{ printf "cmd %q" $var }}` to emit bash commands — it outputs `#cmd ...` which is a comment, not a command
- `-}}` strips the following newline; chaining `#{{ ... -}}` lines concatenates their `#` characters — avoid in loops
- Standalone `if ... then ... fi` blocks must have non-comment content in the `then` clause; merge PPA template calls into blocks that also contain `packages=(...)` code

## Key Conventions

- Prefer editing existing scripts/configs over creating new ones
- When adding a new package, add it to `.chezmoidata.toml` (use the `add-package` skill)
- When adding a managed tool that needs an external binary/repo, also update `.chezmoiexternal.toml`
- When adding OS-conditional logic, mirror the pattern in `.chezmoiignore` to exclude irrelevant files from non-matching OSes
- Script numbering: `0` = init, `1` = package installs, `2-8` = custom installs and tool setup, `9` = post-install config, `z` = finalize
