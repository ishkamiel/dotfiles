#!/bin/bash

USE_SYMBOLS=true
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=true

loadGitStatus() { #{{{
    # Check if we've already got a gitStatus command
    if ! $(type gitStatus &> /dev/null); then
        local filename="${DOTFILES}/bash/lib/gitStatus"
        [ -z "${DOTFILES}" ] && filename="${HOME}${filename}"
        if [ -e  "${filename}" ]; then
            source "${filename}"
        else
            >&2 echo "Cannot find gitStatus file to source!"
        fi
    fi
} #}}}
createTempdir() { #{{{
    local dirname="${1}"
    local tmpdir="${TMPDIR}"
    [ -z "${tmpdir}" ] && tmpdir='/tmp'
    tmpdir="${tmpdir}/${dirname}.${UID}"
    mkdir -p "${tmpdir}"
    echo -ne "${tmpdir}"
} #}}}
getRepositoryNameLength() { #{{{
    local max=0
    for repo in "${repos[@]}"; do
        repo=$(basename ${repo})
        if [ ${max} -lt ${#repo} ]; then
            max=${#repo}
        fi
    done
    echo -ne "${max}"
} #}}}
updateRepo() { #{{{
    local repo="${1}"
    local tmpdir=$(createTempdir ".repo_status.sh")
    local lockfile="${tmpdir}/$(basename ${repo})"

    if [ ! -e "${lockfile}" ]; then
        # TODO: maybe refresh once in a while?
        echo -e "$(date +'%s')" > "${lockfile}"
        git -C ${repo} remote update
    fi
} #}}}
updateAll() { #{{{
    for repo in "${repos[@]}"; do
        if [ -d "${repo}/.git" ]; then
            updateRepo ${repo}
        else
            echo "Can't find git repository at ${repo}"
        fi
    done
} #}}}
showAll() { #{{{
    loadGitStatus
    local repoLen=$(getRepositoryNameLength)

    for repo in "${repos[@]}"; do
        if [ -d "${repo}/.git" ]; then
            status=$(gitStatus ${repo})

            if [[ $status =~ [[:space:]] ]]; then
                printf "%-${repoLen}s %-15s\n" "$(basename ${repo})" "(${status})"
            fi
        else
            echo "Can't find git repository at ${repo}"
        fi
    done

    return 0
} #}}}

if [ -z "${MY_REPOSITORIES}" ]; then
    >&2 echo "MY_REPOSITORIES empty, nothing to do"
    exit 0
fi

repos=(${MY_REPOSITORIES//;/ })

if [ "${1}" = "update" ]; then
    echo "Updating repos in background"
    updateAll &
else
    showAll
fi

# vim: ft=sh fdm=marker foldlevel=0
