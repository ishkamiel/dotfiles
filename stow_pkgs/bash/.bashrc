#!/usr/bin/env bash

__prepend_to_PATH() {
    case ":$PATH:" in
        *:$1:*)
            # echo "$1 already in path, skipping"
            ;; # already in PATH, doing nothing
        *)
            # [ -e "$1" ] || echo "$1 not found, skipping"
            [ -e "$1" ] && export PATH="$1:${PATH}"
            ;;
    esac
}

# pyenv
export PYENV_ROOT="${HOME}/.pyenv"
__prepend_to_PATH "${PYENV_ROOT}/bin"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init --path)"

# rbenv
__prepend_to_PATH "${HOME}/.rbenv/bin"
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"
