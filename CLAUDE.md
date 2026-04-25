# CLAUDE.md

This is an **ishfiles** dotfiles repository for Hans Liljestrand, targeting
Linux (Ubuntu, Fedora) and macOS (Windows support is deferred — see
`TODO.md`).

`ishfiles` is the custom dotfile manager itself. Its source lives upstream
at `github.com/ishkamiel/ishlib` and is wired in here as a git submodule at
`ishlib/`. **The submodule is unpopulated by default** — clone with
`--recurse-submodules`, or run `git submodule update --init` after the
fact, before anything in `ishlib/` (CLI entry point, source, upstream
`CLAUDE.md`) becomes available.

Canonical install path (from `README.md`):

```bash
git clone --recurse-submodules https://github.com/ishkamiel/dotfiles ~/.local/share/ishfiles
~/.local/share/ishfiles/ishlib/bin/ishfiles apply
```

## Repository Structure

```
ishconfig/
  config.toml          # Repo-level settings (e.g. default_shell); lower priority than ~/.config/ishfiles/config.toml
  config-local.toml    # Per-machine prompted variables (machineType, email, isWork, …); each entry may carry isholate = <value> used when `ishfiles apply --isholate` is in effect
  externals.toml       # External git repos pinned by revision (tag or commit) (fzf, oh-my-zsh, pyenv, tpm)
  packages.toml        # Cross-platform packages (cargo, winget)
  packages.unixlike.toml  # Unix-only packages (apt, dnf, brew) — implicit only_on=unixlike
ishscripts/            # Numbered post-install bash scripts (run after packages); contains data/ and lib/ subdirs
ishinstallers/         # Custom per-package installers (powershell, starship)
ishlib/                # Git submodule → github.com/ishkamiel/ishlib (Python pyishlib package + ishfiles CLI). Empty until `git submodule update --init`.
dot_*/                 # Source dotfiles: dot_foo → ~/.foo  (dot_ prefix inherited from chezmoi)
bin/                   # User scripts; currently excluded from home (executable_ prefix not yet handled)
tests/                 # Pytest suite for this repo (script syntax, installer conventions, package lists, shellcheck)
TODO/                  # Deferred work (chezmoi-windows/ reference scripts)
TODO.md                # Deferred work tracking
```

There is **no** top-level `data/` or `lib/` directory; helper data
(`gnome_keybindings`) and helper scripts (`keybindings.pl`) live under
`ishscripts/data/` and `ishscripts/lib/` respectively.

## ishfiles CLI

Subcommands live in the upstream `ishlib` repo (path inside the submodule:
`ishlib/src/pyishlib/ishfiles/commands/`).

| Command | Purpose |
|---|---|
| `apply` | Install dotfiles → packages → scripts in order |
| `diff` | Show what `apply` would change (safe, read-only) |
| `add` | Stage a file into the source tree |
| `install` | Run package installation only |
| `runscripts` | Run `ishscripts/` only |
| `external apply [paths…] [--force]` | Fetch (if stale) and deploy external repos to home |
| `external update [paths…] [-y]` | Check for newer tagged releases and prompt to update pins |
| `external list` | Show pinned revisions and cache status |
| `git` | Run git on the source tree |
| `log` | Show script run history |
| `pd` | Print the dotfiles source directory path |
| `cd` | Spawn a subshell in the dotfiles source directory (see `init` for a real cd) |
| `init [--bash\|--zsh\|--sh]` | Print shell integration code; eval in your rc to make `ishfiles cd` do a real cwd change |

## dot_* Naming

`dot_foo` → `~/.foo`. The `dot_` prefix is read directly by ishfiles (no
template pre-processing step for filenames). Dotfile *contents* can use
`@ish` preprocessing directives (see below).

## `@ish` Directives in ishscripts and ishinstallers

Every file in `ishscripts/` and `ishinstallers/` is preprocessed through
`FilePreprocessor` before hashing or execution. Script metadata lives in a
POSIX no-op heredoc so the source file is always valid bash:

```bash
: <<'__ISH__'
run_when = "onchange"
only_on  = ["linux"]   # optional OS filter
__ISH__
```

Recognised metadata keys:

- `run_when = "onchange"` — script re-runs only when its preprocessed
  content hash changes (analogous to chezmoi's `run_onchange_*`).
- `only_on` / `ignore_on` — OS filter using the same tag set as
  `.ishignore`: `linux`, `macos`, `windows`, `debian`, `fedora`, `unixlike`.
- `tags = [...]` — gate the script on data-variable tags
  (e.g. `["isGnome"]`, `["isGui"]`).
- `cmd = "<binary>"` — runner skips the script if `<binary>` is already
  on `PATH`. Don't duplicate this with an inline `command -v` check; the
  runner gate is sufficient.

Preprocessor variables (`${__ish_<name>}`) and `@ish if` conditionals are
available in both dotfiles and ishscripts; variables come from
`cfg.context.as_dict()`, seeded by `ishconfig/config-local.toml` + platform
detection. Definitive rules live in the upstream `ishlib` `CLAUDE.md`
(visible after `git submodule update --init`).

### Current ishscripts roster

| Script | Notes |
|---|---|
| `50_setup_fzf.sh` | `run_when = "onchange"`; soft-skips if `~/.fzf` external isn't applied yet |
| `90_gnome_shell.sh` | `tags = ["isGnome"]` |
| `91_kitty_dropdown.sh` | Quake-mode kitty via GNOME Shell extension |
| `92_fonts.sh` | `tags = ["isGui"]` |
| `93_vim_plugins.sh` | `run_when = "onchange"` |
| `94_zsh_compile.sh` | `run_when = "onchange"` |
| `95_claude_install.sh` | Installs Claude Code |
| `96_claude_plugins.sh` | Reports missing marketplace plugins (cannot install — Claude Code has no shell-level install CLI) |

### Current ishinstallers

`install_powershell.sh`, `install_starship.sh`. They use the same
`__ISH__` heredoc shape as ishscripts (the metadata block is parseable
TOML — that's all `tests/test_installer_conventions.py` enforces).

## Logging

ishfiles, ishscripts, and `ishlib.sh` share a **unified logging pipeline**.
The definitive rules live in the upstream `ishlib` `CLAUDE.md` once the
submodule is initialised. Do not use `print()` or `echo >&2` for status
output; route everything through the helpers below.

### Logging helpers in ishscripts

Scripts have access to the following helpers (from `ishlib/ishlib.sh`,
sourced by the runner). They honour `ISHLIB_LOG_OUT` for structured
capture; without it they print to stderr.

| Function | Level | Behaviour |
|---|---|---|
| `ish_debug "msg"` | debug | Shown only with `--debug`; logged to run history |
| `ish_info "msg"` | info | Shown with `-v`; logged to run history |
| `ish_warning "msg"` | warning | Shown by default; does not stop apply |
| `ish_error "msg"` | error | Shown by default; does not stop apply |
| `ish_critical "msg"` | critical | Shown by default; exits 1 and aborts remaining scripts |

Use `ish_warning` + `exit 0` for optional prerequisites that may not be
present (e.g., "external not yet applied — skipping").

## Externals

External git repos/archives are declared in `ishconfig/externals.toml` and
managed by `ishfiles external`. Pinned entries:

| Path | Source | Pinned version |
|---|---|---|
| `~/.fzf` | github.com/junegunn/fzf | `v0.70.0` |
| `~/.oh-my-zsh` | github.com/ohmyzsh/ohmyzsh | commit `7de13621b376ab5e616dbc3729b52fbfde92d0e1` |
| `~/.pyenv` | github.com/pyenv/pyenv | `v2.6.26` |
| `~/.tmux/plugins/tpm` | github.com/tmux-plugins/tpm | `v3.1.0` |

Update pins with `ishfiles external update`.

## Package Data

Cross-platform packages (cargo, winget) live in `ishconfig/packages.toml`.
Unix packages live in `ishconfig/packages.unixlike.toml` — every entry
there has an implicit `only_on = ["unixlike"]`; an explicit `only_on` is
prepended with `unixlike` (so `["debian"]` becomes Debian-family Linux
only).

Fields per entry:

| Field | Description |
|---|---|
| `apt`, `dnf`, `brew`, `cargo`, `winget` | Package name for that manager |
| `only_on` | Restrict to OSes — ALL listed tags must match (AND) |
| `ignore_on` | Skip on these OSes — ANY listed tag matching triggers skip (OR) |
| `tags` | Category list (see below); empty/absent = installed on all non-min machines |
| `optional = true` | Suppress install errors if package unavailable |
| `cmd` | Command name used to check if already installed (via `which`) |
| `pref` | Preferred installer order |

Tag families (from `ishconfig/config-local.toml`):

- `machineType` is `ordered_tags` with values `["min", "def", "personal"]`
  — packages tagged `["min"]` install everywhere; `["def"]` skip on min
  machines; `["personal"]` only on personal machines.
- Booleans (default `false`): `needBuildTools`, `isWork`, `isGui`,
  `isGnome`, `isGaming`. Use `!isWork` to negate.

Each data variable can carry an `isholate = <value>` field used when
`ishfiles apply --isholate` is in effect (see `config-local.toml`).

## `.ishignore`

Repo-infrastructure files excluded from home deployment. Uses the same OS
tag set as `@ish` directives. Currently excludes `.envrc`, `.github`,
`CLAUDE.md`, `README.md`, `tests/`, `bin/`, `pytest.ini`, `pyproject.toml`,
`ishlib`, `TODO/`, `TODO.md`, dev-only files (`.cache`, `.direnv`,
`.venv`, `**/*.pyc`, `**/__pycache__`), and a few specific files we want
in the repo but not in `$HOME`.

`bin/` is excluded because the `executable_` prefix isn't handled by
ishfiles yet (see `TODO.md`); current contents are `executable_tm` and
`executable_vncstart`.

## Python toolchain

- `.python-version` pins the interpreter to **3.14.3 exactly**. The
  `layout_pyenv` override in `.envrc` does *not* fuzzy-match — partial
  versions like `3.14` will fail. Install with `pyenv install 3.14.3`.
- `.envrc` requires `pyenv`, creates `.venv/`, and auto-installs the `dev`
  dependency group from `pyproject.toml`. It hashes `pyproject.toml` to
  detect changes; force a reinstall with `rm .venv/.requirements-installed`
  (or `rm -rf .venv`).
- `pyproject.toml` uses **PEP 735 dependency groups**:
  - `runtime` — `tomli; py<3.11`, `shtab`
  - `test` — `pytest`, `pytest-xdist`
  - `dev` — `runtime` + `test` + `cerberus`, `jsonschema`, `mypy`

  Install manually with `pip install --group dev`.

## SPDX Headers

All shell and Python files must have:

```bash
# SPDX-License-Identifier: MIT
# Copyright (C) <year> Hans Liljestrand <hans@liljestrand.dev>
```

The pre-commit hook auto-inserts the header (with current year) for files
matching `(dot_tmux\.conf|dot_zshrc|dot_zprofile|dot_profile|dot_bashrc|\.(sh.tmpl|zsh.tmpl|sh|zsh|py))$`.

## Pre-commit

`.pre-commit-config.yaml` runs:

- `pre-commit-hooks`: `check-ast`, `check-case-conflict`,
  `check-executables-have-shebangs`, `check-json`, `check-merge-conflict`,
  `check-toml`, `check-yaml`, `detect-private-key`, `end-of-file-fixer`,
  `fix-byte-order-marker`, `fix-encoding-pragma`, `mixed-line-ending`,
  `pretty-format-json` (autofix), `trailing-whitespace`.
- `black` 24.8.0 on Python files.
- `insert-license` (Lucas-C) for the SPDX header.
- A **local `pytest` hook** (`pass_filenames: false`) that runs the full
  test suite on every commit. Be aware: this means commits cost a full
  test-run; run `pytest` ahead of time to fail fast.

Run all hooks manually with `pre-commit run --all-files`.

## Testing

The test suite is at the **repo root**:

```bash
pytest             # equivalent to `pytest tests/` thanks to pytest.ini
pytest tests/      # explicit form
```

`pytest.ini` sets `addopts = -d --numprocesses=auto` (parallel via
`pytest-xdist`).

Test modules in `tests/`:

| File | Coverage |
|---|---|
| `conftest.py` | Parametrises `src_file_bash`, `src_file_zsh`, `ishinstaller_file` fixtures from shebang/path detection |
| `test_script_syntax.py` | `bash -n` / `zsh -n` syntax checks for `ishscripts/`, `ishinstallers/`, `bin/executable_*`, `dot_bashrc`, `dot_profile`, `dot_zshrc`, `dot_zprofile` |
| `test_installer_conventions.py` | Validates `__ISH__` metadata blocks in `ishinstallers/` are valid TOML |
| `test_package_lists.py` | Detects duplicate package names across `ishconfig/packages*.toml` for apt/dnf/brew/cargo/winget |
| `test_shellcheck_bash.py` | Runs `shellcheck` on bash files |

## CI

`.github/workflows/tests.yml` runs on push and PRs to `main`:

- Matrix: `ubuntu-latest`, `macos-latest`.
- Installs `shellcheck` (and `zsh` on Linux) via the platform package
  manager.
- Sets up Python from `.python-version`, then
  `pip install --group test --group runtime`.
- Runs `pytest tests/`.

## ishfiles Manual Testing Safety

**Never run `ishfiles apply`, `install`, or `runscripts` against the real
home directory.** These commands modify files and install packages. Only
use `ishfiles diff` for manual testing, and always point to safe temporary
directories. Requires the `ishlib/` submodule to be initialised.

```bash
TEST_HOME=$(mktemp -d)
TEST_CONFIG="$TEST_HOME/.config/ishfiles/config.toml"
mkdir -p "$(dirname "$TEST_CONFIG")"

# Safe: diff only, temp home, temp config
./ishlib/bin/ishfiles --home "$TEST_HOME" -s "$(pwd)" -c "$TEST_CONFIG" diff

# Inspect results
cat "$TEST_CONFIG"

# Clean up
rm -rf "$TEST_HOME"
```

The `--home`, `-s` (source), and `-c` (config) flags redirect all file
operations away from `$HOME`. The repo's own `tests/` suite uses temp
directories and is always safe to run.
