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

## isholate: per-file opt-in host mounts

**Context:** `--ro-home` was removed because it bind-mounted the entire
host home over the container home, shadowing dotfiles written by
`ishfiles apply` and making isolation pointless. The container always
gets a fresh `$HOME` now.

**Why deferred:** No concrete use case yet. When one arises (e.g., sharing
`~/.ssh` or `~/.gitconfig` read-only), the right design is per-file opt-in
flags like `--mount ~/.ssh:ro` rather than a whole-home mount.

**How to pick up:** Add `--mount <src>:<mode>` (repeatable) to `cli.py`
argparse, pass the list into `launch_and_exec`, and add individual
`incus config device add … disk source=… path=… readonly=true shift=true`
calls in step 5. Mount paths must land outside `/home/$username` or
after provisioning to avoid shadowing generated dotfiles.

---

## isholate: `--network=host` escape hatch

**Context:** When the Incus bridge has broken NAT (ufw/firewalld/sysctl), the
container network pre-flight aborts with a diagnostic. A `--network=host` flag
would let users bypass the bridge entirely and share the host's network stack.

**Why deferred:** The incus way to do this is non-trivial and has security
implications (full host network stack exposure, no NAT isolation).

**How to pick up:** Expose `lxc.net.0.type = none` via `incus config set
<name> raw.lxc` after `incus init`, add a `--network=host` flag to
`src/pyishlib/isholate/cli.py`, and skip the pre-flight probe when host
networking is active.

---

## isholate: `--apt-mirror` override

**Context:** If the container can reach the internet but the default Ubuntu
mirrors are slow or unreachable, users currently have no way to point apt at a
custom mirror (e.g., a local apt-cacher-ng).

**Why deferred:** Needs a way to rewrite `/etc/apt/sources.list` (or the
`sources.list.d/*.list` variant in Ubuntu Noble) inside the container. Low
urgency — the network pre-flight diagnostic handles the common case.

**How to pick up:** Accept `--apt-mirror=<url>` in `cli.py`, pass it to
`_provision`, and add a `sed` / `tee` step that replaces the archive URL in
`/etc/apt/sources.list.d/ubuntu.sources` before the apt bootstrap.

---

## Missing ishlib helpers in install_powershell.sh

**File:** `ishinstallers/install_powershell.sh` (lines 39, 44)

**What:** The installer calls `ish_apt_add_key` and `ish_apt_add_repo`, two
helpers that are not defined in the current `ishlib.sh`. The installer will
fail at runtime on Debian-family systems when it reaches those calls.

**Why deferred:** Discovered during a logging-alias sweep; fixing requires
either adding the helpers back to `ishlib/src/sh/` (and rebuilding
`ishlib.sh`) or rewriting the installer to inline the steps. That is a
separate ishlib design decision.

**How to pick up:** Either:
1. Add `ish_apt_add_key <url> <name>` and `ish_apt_add_repo <name> <deb-line>`
   to `ishlib/src/sh/` (rebuild with `make ishlib.sh`), or
2. Rewrite the relevant section of `install_powershell.sh` to inline the
   `curl | gpg --dearmor` key import and `/etc/apt/sources.list.d/*.list`
   creation steps directly.
