---
name: add-test
description: Add a new pytest test to this chezmoi dotfiles repo. Use when the user asks to add a test, extend test coverage, or test a new script/template/convention.
argument-hint: "<what to test>  # e.g. 'syntax check new helper', 'rendered output of run_onchange_3_foo.sh.tmpl'"
---

# Add a Test

Add a new pytest test to the appropriate file, wiring up any needed fixtures in `conftest.py`.

## Test file map

| What you're testing | File |
|---|---|
| Shell syntax (`bash/zsh/sh -n`) on source or rendered templates | `tests/test_script_syntax.py` |
| `shellcheck` on bash scripts | `tests/test_shellcheck_bash.py` |
| `chezmoi execute-template` output (package lists, PPAs) | `tests/test_chezmoi_templates.py` |
| Helper script naming/structure conventions | `tests/test_helper_conventions.py` |
| `.chezmoidata.toml` data integrity | `tests/test_package_lists.py` |

## Fixture / parametrisation pattern

All file collections and per-file parametrisation live in `tests/conftest.py` — `pytest_generate_tests` dispatches on fixture name. The pattern for a new file collection:

```python
# conftest.py — add to _source_candidates or a new helper, then wire up in pytest_generate_tests:
if "src_file_my_type" in metafunc.fixturenames:
    files = _my_file_list(root_path)
    metafunc.parametrize("src_file_my_type", files, ids=[str(f.relative_to(root_path)) for f in files])
```

Then in the test file:

```python
def test_my_check(src_file_my_type) -> None:
    ...
```

## Rendered-template syntax check pattern

For `.sh.tmpl` files, render via chezmoi before checking:

```python
def test_check_bash_n_rendered(src_file_bash_tmpl) -> None:
    rendered = _render_template(src_file_bash_tmpl)   # chezmoi execute-template --file
    _check_shell_syntax("bash", rendered, src_file_bash_tmpl.name)
```

`_render_template` and `_check_shell_syntax` are already defined in `test_script_syntax.py`.

## Steps

1. Read the relevant existing test file and `tests/conftest.py` to understand the current patterns.
2. Identify whether a new fixture/parametrisation is needed in `conftest.py` or whether an existing one suffices.
3. Add the fixture wiring to `conftest.py` if needed.
4. Add the test function to the appropriate test file.
5. Run `./run_pytest.sh <test-file>` to verify the new test is collected and passes.
6. If the test is for a `.sh.tmpl` file, also run `./run_pytest.sh tests/test_script_syntax.py` to confirm no regressions.
