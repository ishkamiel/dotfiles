---
name: run-tests
description: Run the pytest test suite for the ishfiles dotfiles repository. Use when the user asks to run tests, verify changes, or check that everything still passes. Triggers on requests to validate, test, or verify dotfiles conventions, package lists, script syntax, or shellcheck.
argument-hint: "[pytest-args]  # e.g. -k test_shellcheck, tests/test_script_syntax.py, -x"
---

# Run Tests

The ishfiles root-level test suite lives in `tests/`. Run from the ishfiles root (`/home/ishkamiel/.local/share/ishfiles`). These tests cover dotfiles conventions: package list validity, installer script syntax, and shellcheck on bash scripts.

For ishlib's own test suite (Python library + shell functions), use the `run-tests` skill from within `ishlib/`.

## Quick reference

| Goal | Command |
|------|---------|
| All tests | `pytest` |
| Specific file | `pytest tests/test_script_syntax.py` |
| By name pattern | `pytest -k "test_shellcheck"` |
| Stop on first failure | `pytest -x` |
| Verbose output | `pytest -v` |
| Shellcheck only | `pytest tests/test_shellcheck_bash.py` |
| Syntax only | `pytest tests/test_script_syntax.py` |
| Package list checks | `pytest tests/test_package_lists.py` |

Tests run in parallel by default (`--numprocesses=auto`).

## Steps

1. Run `pytest $ARGUMENTS` from the ishfiles root (pass through any user-supplied args).
2. If tests fail, show the relevant failure output and diagnose the root cause.
3. Do not re-run the same failing command — fix the issue first.
