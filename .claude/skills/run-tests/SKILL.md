---
name: run-tests
description: Run the pytest test suite for this chezmoi dotfiles repo. Use when the user asks to run tests, verify changes, or check that everything still passes.
argument-hint: "[pytest-args]  # e.g. -k test_shellcheck, tests/test_script_syntax.py, -x"
---

# Run Tests

Run the test suite via `./run_pytest.sh`, which activates the virtualenv and forwards all arguments to pytest.

## Quick reference

| Goal | Command |
|------|---------|
| All tests | `./run_pytest.sh` |
| Specific file | `./run_pytest.sh tests/test_script_syntax.py` |
| Specific test | `./run_pytest.sh -k test_check_bash_n_rendered` |
| Stop on first failure | `./run_pytest.sh -x` |
| Verbose output | `./run_pytest.sh -v` |
| Shellcheck only | `./run_pytest.sh tests/test_shellcheck_bash.py` |
| Syntax only | `./run_pytest.sh tests/test_script_syntax.py` |
| Template output | `./run_pytest.sh tests/test_chezmoi_templates.py` |

## Steps

1. Run `./run_pytest.sh $ARGUMENTS` (pass through any user-supplied pytest args).
2. If tests fail, show the relevant failure output and diagnose the root cause.
3. Do not re-run the same failing command repeatedly — fix the issue first.
