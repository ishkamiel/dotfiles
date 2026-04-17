---
name: add-package
description: Add one or more packages to the ishfiles package config in this dotfiles repo. Use when the user asks to add a package, install a tool via apt/dnf/cargo/winget/brew, or register a new package for cross-platform installation.
argument-hint: "<logical-name> [apt=<pkg>] [dnf=<pkg>] [winget=<id>] [cargo=<crate>] [brew=<pkg>] [flags...]"
---

# Add Package to ishconfig

Add one or more packages to the ishfiles package config, then verify with tests. Add package to all relevant managers when available, even if the user only mentioned one. If the user only mentioned a package name without manager-specific names, look them up or ask the user.

## Arguments

`$ARGUMENTS` may be:
- A bare package name (e.g., `htop`) — Claude looks up or asks for manager-specific names
- Key=value pairs (e.g., `htop apt=htop dnf=htop`)
- Just a description (e.g., "add htop for linux") — Claude infers the rest

## Which file to edit

| Package type | File |
|---|---|
| Unix-only (apt/dnf/brew) | `ishconfig/packages.unixlike.toml` |
| Cross-platform or cargo/winget | `ishconfig/packages.toml` |

## Package fields

Each entry looks like:

```toml
[logical_key]
apt    = "<apt-package-name>"        # omit if unavailable
dnf    = "<dnf-package-name>"        # omit if unavailable
brew   = "<brew-formula>"            # omit if unavailable
cargo  = "<crate-name>"              # omit if unavailable
winget = "<Vendor.PackageId>"        # omit if unavailable
tags   = ["<tag>"]                   # see tags table below; omit for default non-min
only_on  = ["<os>"]                  # optional: restrict to subset of OSes
ignore_on = ["<os>"]                 # optional: skip on these OSes
optional = true                      # suppress install errors
```

**Logical key**: lowercase, underscores, no leading digits. Stable tool identifier, not manager-specific (e.g., `fd_find`, not `fd-find`).

## Tags

| Tag | Meaning |
|---|---|
| *(no tags field)* | Default — installed on all non-min machines |
| `["min"]` | Core — installed on all machine types including min |
| `["def"]` | Default — installed on all non-min machines (explicit form) |
| `["needBuildTools"]` | Build tools — only when needBuildTools is true |
| `["isWork"]` | Work-only — only when isWork is true |
| `["isGui"]` | GUI packages |
| `["isGnome"]` | GNOME-specific packages |
| `["isGaming"]` | Gaming packages |

`optional = true` can be combined with any tags entry.

OS values for `only_on`/`ignore_on`: `linux`, `macos`, `windows`, `debian`, `fedora`, `unixlike`.

## Section placement in packages.unixlike.toml

Place the entry in the correct section and keep entries alphabetical by logical key within each section:

| Tags | Section |
|---|---|
| `["min"]` | Core / minimum packages |
| `["def"]` or no tags | Default packages |
| `["needBuildTools"]` | Build tools |
| `["isGui"]` | GUI packages |
| `["isGnome"]` | GNOME packages |
| `["isWork"]` | Work packages |
| `["isGaming"]` | Gaming packages |

## Steps

1. Read `ishconfig/packages.unixlike.toml` (and `ishconfig/packages.toml` if cross-platform) to understand existing entries and locate the right insertion point.
2. Determine the logical key and manager-specific names (ask the user if unclear).
3. Determine the correct tags and file based on what the user described.
4. Insert the new entry in the correct alphabetical position within the correct section.
5. Run `pytest` from the repo root to verify no regressions.
6. Report what was added and confirm the tests pass.
