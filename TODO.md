# TODO — Deferred Items

This file documents work that was intentionally deferred. None of it is
urgent; the system is fully functional without it. Each section states what
was deferred, why, and where to pick it up.

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

## rustup on older distros

**Why noted:** `apt = "rustup"` / `dnf = "rustup"` works on recent distros
but older ones (e.g., Ubuntu 20.04) don't have rustup in their default repos.
The upstream `rustup-init` script is the portable fallback.

**How to pick up:** Add a custom installer `ishinstallers/install_rustup.sh`
that falls back to `curl https://sh.rustup.rs | sh` when the distro package
is unavailable.
