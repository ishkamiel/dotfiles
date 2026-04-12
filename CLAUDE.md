# CLAUDE.md

This is an **ishfiles** dotfiles repository for Hans Liljestrand, targeting
Linux (Ubuntu, Fedora) and macOS (Windows support is deferred — see TODO.md).

`ishfiles` is the custom dotfile manager that lives in `ishlib/`. Its source
and documentation are in `ishlib/CLAUDE.md`.

## Repository Structure

```
ishconfig/
  data.toml            # User-specific variables (machineType, email, isWork, …)
  externals.toml       # External git repos pinned by tag (fzf, oh-my-zsh, pyenv, tpm)
  packages.toml        # Cross-platform packages (cargo, winget)
  packages.unixlike.toml  # Unix-only packages (apt, dnf, brew) — implicit only_on=unixlike
ishscripts/            # Numbered post-install bash scripts (run after packages)
ishinstallers/         # Custom per-package installers (powershell, starship)
ishlib/                # Python package pyishlib.ishfiles + ishfiles CLI
dot_*/                 # Source dotfiles: dot_foo → ~/.foo  (dot_ prefix inherited from chezmoi)
bin/                   # User scripts (~/.local/bin); excluded from home until executable_ support added
data/                  # Data files (gnome_keybindings)
lib/                   # Helper scripts (keybindings.pl)
TODO/                  # Deferred work (chezmoi-windows/ reference scripts)
TODO.md                # Deferred work tracking
```

## ishfiles CLI

Subcommands in `ishlib/src/pyishlib/ishfiles/commands/`:

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

## dot_* Naming

`dot_foo` → `~/.foo`. The `dot_` prefix is read directly by ishfiles (no
template pre-processing step for filenames). Dotfile *contents* can use
`@ish` preprocessing directives (see below).

## `@ish` Directives in ishscripts

Every file in `ishscripts/` is preprocessed through `FilePreprocessor`
before hashing or execution (`script_runner.py:195`). Script metadata lives
in a POSIX no-op heredoc so the source file is always valid bash:

```bash
: <<'__ISH__'
run_when = "onchange"
only_on  = ["linux"]   # optional OS filter
__ISH__
```

`run_when = "onchange"` — script re-runs only when its preprocessed content
hash changes (analogous to chezmoi's `run_onchange_*`).

`only_on` / `ignore_on` — OS filter using the same tag set as `.ishignore`:
`linux`, `macos`, `windows`, `debian`, `fedora`, `unixlike`.

Preprocessor variables (`${__ish_<name>}`) and `@ish if` conditionals are
available in both dotfiles and ishscripts; variables come from
`cfg.context.as_dict()`, seeded by `ishconfig/data.toml` + platform
detection. See `ishlib/CLAUDE.md` §DotfileContext for details.

## Logging in ishscripts

Scripts have access to three logging helpers (from `ishlib/ishlib.sh`, sourced
by the runner):

| Function | Severity | Behaviour |
|---|---|---|
| `ish_info "msg"` | Info | Printed; logged to run history |
| `ish_warn "msg"` | Warning | Printed; does not stop apply |
| `ish_error "msg"` | Error | Printed; exits script with error |

Use `ish_warn` + `exit 0` for optional prerequisites that may not be present
(e.g., "external not yet applied — skipping").

## Externals

External git repos/archives are declared in `ishconfig/externals.toml` and
managed by `ishfiles external`. Pinned entries:

| Path | Source | Pinned version |
|---|---|---|
| `~/.fzf` | github.com/junegunn/fzf | v0.70.0 |
| `~/.oh-my-zsh` | github.com/ohmyzsh/ohmyzsh | latest main |
| `~/.pyenv` | github.com/pyenv/pyenv | v2.6.26 |
| `~/.tmux/plugins/tpm` | github.com/tmux-plugins/tpm | v3.1.0 |

Update pins with `ishfiles external update`.

## Package Data (`ishconfig/packages.unixlike.toml`)

All Unix packages are declared under top-level TOML tables. Fields:

| Field | Description |
|---|---|
| `apt`, `dnf`, `brew` | Package name for that manager |
| `only_on` | Restrict to a subset of OSes (e.g. `["debian"]`) |
| `ignore_on` | Skip on these OSes |
| `tags` | `["min"]` = all machines; `["def"]` = non-min; `["needBuildTools"]`, `["isWork"]`, `["isGui"]`, `["isGnome"]`, `["isGaming"]` — filtered by data variables |
| `optional = true` | Suppress install errors if package unavailable |

Cross-platform packages (cargo, winget) live in `ishconfig/packages.toml`.

## SPDX Headers

All shell and Python files must have:

```bash
# SPDX-License-Identifier: MIT
# Copyright (C) <year> Hans Liljestrand <hans@liljestrand.dev>
```

Enforced by pre-commit. The pre-commit config also checks: trailing
whitespace, TOML/JSON/YAML validity, no private keys.

## Testing

The primary test suite is `ishlib/pytest/` — run it via:

```bash
cd ishlib && make verify    # build + test
cd ishlib && pytest         # tests only
```

The repo root has a direnv-managed venv (`.envrc` reads `requirements-dev.txt`
via `layout pyenv`). Pre-commit runs on every commit.

```bash
pre-commit run --all-files   # run all hooks manually
```

## ishfiles Manual Testing Safety

**Never run `ishfiles apply`, `install`, or `runscripts` against the real
home directory.** These commands modify files and install packages. Only use
`ishfiles diff` for manual testing, and always point to safe temporary
directories:

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
operations away from `$HOME`. Unit tests in `ishlib/pytest/` use temp
directories and are always safe to run.
