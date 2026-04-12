# TODO — Deferred Items

This file documents work that was intentionally deferred from the
chezmoi → ishfiles migration. None of it is urgent; the system is fully
functional without it. Each section states what was deferred, why, and
where to pick it up.

---

## Windows PowerShell scripts

**Files:** `TODO/chezmoi-windows/` (verbatim copy from `.chezmoiscripts/windows/`)

**What they do:**

| Script | Purpose |
|---|---|
| `run_0_init.ps1.tmpl` | Error-log bootstrap |
| `run_onchange_1_install_winget.ps1.tmpl` | Package installs via winget |
| `run_onchange_2_install_fonts.ps1.tmpl` | FiraCode font install |
| `run_onchange_9_configure_pwsh.ps1.tmpl` | PowerShell profile setup |
| `run_onchange_9_configure_windows_terminal.ps1.tmpl` | Windows Terminal config |
| `run_z_finalize.ps1.tmpl` | Error-summary printout |

**Why deferred:**

- No `pwsh` execution story in ishfiles yet (the `DotfileScript` runner
  only handles `sh`/`bash`/`zsh`; PowerShell subprocess handling is a
  separate effort).
- No Windows CI in the GitHub Actions workflows — validating ported scripts
  requires a real or emulated Windows environment.

**How to pick up:**

1. Add a `ps1` shebang branch to `dotfile_script.py` that invokes `pwsh -File`.
2. Add a Windows runner to `.github/workflows/pytest.yml`.
3. Port scripts from `TODO/chezmoi-windows/` into `ishscripts/` (PowerShell
   scripts, not bash), replacing chezmoi template syntax with `@ish`
   directives.

---

## External git repos / archives (fzf, oh-my-zsh, pyenv, tpm)

**File:** `TODO/externals.toml` (verbatim copy of `.chezmoiexternal.toml`)

**What they manage:**

| Repo | Version pinned | Purpose |
|---|---|---|
| `~/.fzf` | v0.70.0 | Fuzzy finder; `ishscripts/50_setup_fzf.sh` depends on it |
| `~/.oh-my-zsh` | latest main | Zsh framework |
| `~/.pyenv` | latest master | Python version manager |
| `~/.tmux/plugins/tpm` | latest master | Tmux plugin manager |

**Why deferred:**

- Externals (cloned git repos / downloaded archives) are a distinct
  subsystem that cross-cuts apply ordering — they must run before scripts
  that depend on them (e.g., `50_setup_fzf.sh` needs `~/.fzf`).
- chezmoi's `external` mechanism is tightly coupled to its state model;
  replicating it cleanly in ishfiles is a larger piece of work.

**How to pick up:**

1. Add an `ishexternals/` directory or a `externals.toml` config file.
2. Implement an `externals` subcommand (or phase in `apply`) that clones /
   updates pinned repos before scripts run.
3. Re-enable `50_setup_fzf.sh` fully once `~/.fzf` is guaranteed to exist.
4. Track pinned revisions via `update-externals.sh` or an equivalent tool.

**Current state:** `50_setup_fzf.sh` issues `ish_warn` if `~/.fzf` is
missing rather than erroring, so the rest of the apply succeeds on machines
where the external hasn't been manually cloned yet.

---

## rustup on older distros

**Why noted:** `apt = "rustup"` / `dnf = "rustup"` works on recent distros
but older ones (e.g., Ubuntu 20.04) don't have rustup in their default repos.
The upstream `rustup-init` script is the portable fallback.

**How to pick up:** Add a custom installer `ishinstallers/install_rustup.sh`
that falls back to `curl https://sh.rustup.rs | sh` when the distro package
is unavailable.

---

## pyenv

Depends on the external (see above). Listed here as a reminder that pyenv
setup scripts may be needed once externals are in place.
