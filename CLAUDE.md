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

- `install_helpers.sh` — `log_error`, `verbose_echo`, `__install_packages`, `downloadFile`, `running_gnome`
- `install_helpers_apt.sh`, `_dnf.sh`, `_brew.sh`, `_snap.sh` — per-manager install functions
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

## Key Conventions

- Prefer editing existing scripts/configs over creating new ones
- When adding a new managed tool, add it to the appropriate install script and update `.chezmoiexternal.toml` if it needs a binary/repo pulled externally
- When adding OS-conditional logic, mirror the pattern in `.chezmoiignore` to exclude irrelevant files from non-matching OSes
- Script numbering: `0` = init, `1` = package installs, `2-8` = custom installs and tool setup, `9` = post-install config, `z` = finalize
