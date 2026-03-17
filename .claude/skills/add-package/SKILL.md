---
name: add-package
description: Add one or more packages to .chezmoidata.toml in this chezmoi dotfiles repo. Use when the user asks to add a package, install a tool via apt/dnf/cargo/winget/brew, or register a new package for cross-platform installation.
argument-hint: "<logical-name> [apt=<pkg>] [dnf=<pkg>] [winget=<id>] [cargo=<crate>] [brew=<pkg>] [flags...]"
---

# Add Package to .chezmoidata.toml

Add one or more packages to `.chezmoidata.toml`, then verify with tests.

## Arguments

`$ARGUMENTS` may be:
- A bare package name (e.g., `htop`) — Claude looks up or asks for manager-specific names
- Key=value pairs (e.g., `htop apt=htop dnf=htop`)
- Just a description (e.g., "add htop for linux") — Claude infers the rest

## Package fields

Each entry in `.chezmoidata.toml` looks like:

```toml
[packages.<logical_key>]
  apt    = "<apt-package-name>"        # omit if unavailable
  dnf    = "<dnf-package-name>"        # omit if unavailable
  brew   = "<brew-formula>"            # omit if unavailable
  cargo  = "<crate-name>"              # omit if unavailable
  winget = "<Vendor.PackageId>"        # omit if unavailable
  # Exactly one flag (or none for default non-min packages):
  min         = true   # install everywhere, including "min" machines
  build_tools = true   # only when needBuildTools is true
  work        = true   # only when isWork is true
  no_work     = true   # only when isWork is false
  gaming      = true   # only when isGaming is true
  personal    = true   # only when machineType == "personal"
  optional    = true   # suppress install errors (combine with any flag above)
```

**Logical key** (`<logical_key>`): lowercase, underscores, no leading digits. Should be a stable identifier for the tool, not manager-specific (e.g., `fd_find`, not `fd-find`).

## Section placement

Place the new entry in the correct section of `.chezmoidata.toml`:

| Flag | Section |
|------|---------|
| `min = true` | Core / minimum packages |
| *(none)* | Non-minimum packages |
| `build_tools = true` | Build tools |
| `work = true` | Work packages |
| `no_work = true` | Non-minimum packages (note `no_work` flag) |
| `gaming = true` | Gaming packages |
| `personal = true` | Personal packages |
| Windows-only (`winget` only, no unix managers) | Windows only |

Within each section, keep entries in alphabetical order by logical key.

## Steps

1. Read `.chezmoidata.toml` to understand existing entries and locate the right insertion point.
2. Determine the logical key and manager-specific names (ask the user if unclear).
3. Determine the correct flag(s) based on what the user described.
4. Insert the new entry in the correct alphabetical position within the correct section.
5. Run `./run_pytest.sh tests/test_chezmoi_templates.py` to verify no regressions.
6. Report what was added and confirm the tests pass.
