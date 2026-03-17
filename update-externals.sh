#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 Hans Liljestrand <hans@liljestrand.dev>
#
# Update revision pins in .chezmoiexternal.toml.
# Uses the latest release tag for repos that publish releases,
# and the latest master commit for repos that don't (oh-my-zsh).
#
# When a revision changes, run 'chezmoi apply' to let chezmoi fetch and apply
# the new revision (refreshPeriod = 168h in .chezmoiexternal.toml ensures
# chezmoi re-fetches externals on each weekly apply cycle).
#
# Usage: ./update-externals.sh [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTERNAL="${SCRIPT_DIR}/.chezmoiexternal.toml"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

gh_api() {
    curl -sf --retry 3 \
        -H "Accept: application/vnd.github+json" \
        ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
        "https://api.github.com/$1"
}

latest_release() {
    gh_api "repos/$1/releases/latest" | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])"
}

latest_tag() {
    gh_api "repos/$1/tags" | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['name'])"
}

latest_commit() {
    local branch="${2:-master}"
    gh_api "repos/$1/commits/${branch}" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])"
}

# set_revision URL NEW_REV
# Updates the revision in .chezmoiexternal.toml.
set_revision() {
    local url="$1"
    local new_rev="$2"
    local old_rev
    old_rev=$(python3 -c "
import re
content = open('${EXTERNAL}').read()
m = re.search(r'url = \"${url}\"[^\n]*\n\s*revision = \"([^\"]+)\"', content)
print(m.group(1) if m else '')
")
    if [[ -z "${old_rev}" ]]; then
        echo "  WARNING: could not find revision for ${url}" >&2
        return 0
    fi
    if [[ "${old_rev}" == "${new_rev}" ]]; then
        echo "  up to date: ${url##*/} (${new_rev})"
        return 0
    fi
    echo "  updating:  ${url##*/}  ${old_rev} -> ${new_rev}"
    if [[ "${DRY_RUN}" == 0 ]]; then
        python3 -c "
import re
content = open('${EXTERNAL}').read()
pattern = r'(url = \"${url}\"[^\n]*\n\s*)(revision = \"[^\"]+\")'
result = re.sub(pattern, r'\1revision = \"${new_rev}\"', content)
open('${EXTERNAL}', 'w').write(result)
"
    fi
}

# set_script_revision SCRIPT_FILE MARKER NEW_REV
# Updates a '# MARKER: REV' comment line in a script file (used to trigger
# run_onchange_ re-execution when the external version changes).
set_script_revision() {
    local script="$1"
    local marker="$2"
    local new_rev="$3"
    local old_rev
    old_rev=$(python3 -c "
import re
content = open('${SCRIPT_DIR}/${script}').read()
m = re.search(r'# ${marker}: (\S+)', content)
print(m.group(1) if m else '')
")
    if [[ -z "${old_rev}" ]]; then
        echo "  WARNING: could not find '${marker}' marker in ${script}" >&2
        return 0
    fi
    if [[ "${old_rev}" == "${new_rev}" ]]; then
        return 0
    fi
    echo "  updating:  ${script}  ${old_rev} -> ${new_rev}"
    if [[ "${DRY_RUN}" == 0 ]]; then
        python3 -c "
import re
path = '${SCRIPT_DIR}/${script}'
content = open(path).read()
result = re.sub(r'(# ${marker}: )\S+', r'\g<1>${new_rev}', content)
open(path, 'w').write(result)
"
    fi
}

echo "Fetching latest versions..."

fzf_rev=$(latest_release "junegunn/fzf")
fzftab_rev=$(latest_tag "Aloxaf/fzf-tab")
pyenv_rev=$(latest_release "pyenv/pyenv")
omz_rev=$(latest_commit "ohmyzsh/ohmyzsh" "master")
tpm_rev=$(latest_release "tmux-plugins/tpm")

echo ""
echo "Updating ${EXTERNAL}:"
set_revision "https://github.com/junegunn/fzf.git"           "${fzf_rev}"
set_revision "https://github.com/Aloxaf/fzf-tab.git"         "${fzftab_rev}"
set_revision "https://github.com/pyenv/pyenv.git"            "${pyenv_rev}"
set_revision "https://github.com/ohmyzsh/ohmyzsh.git"        "${omz_rev}"
set_revision "https://github.com/tmux-plugins/tpm.git"       "${tpm_rev}"

echo ""
echo "Updating run_onchange scripts:"
set_script_revision \
    ".chezmoiscripts/unix-like/run_onchange_2_setup_fzf.sh.tmpl" \
    "fzf-revision" "${fzf_rev}"
set_script_revision \
    ".chezmoiscripts/unix-like/run_onchange_6_setup_fzf_tab.sh.tmpl" \
    "fzf-tab-revision" "${fzftab_rev}"

if [[ "${DRY_RUN}" == 1 ]]; then
    echo ""
    echo "(dry run — no changes written)"
else
    echo ""
    echo "Done. Run 'chezmoi apply' to apply the updated externals."
fi

# vim: set ft=bash shiftwidth=4 tabstop=4:
