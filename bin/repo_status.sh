#!/bin/bash

USE_SYMBOLS=true

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
sourceGitShPrompt() { #{{{
    if [ "$(declare -f __git_ps1 > /dev/null; echo $?)" = 1 ]; then
        source "/usr/lib/git-core/git-sh-prompt"
        if [ "$(declare -f __git_ps1 > /dev/null; echo $?)" = 1 ]; then
            echo "Failed to load __git_ps1"
            return 0
        fi
    fi
} #}}}
gitStatus() { #{{{
    # Load the git-core git-sh-prompt thing
    sourceGitShPrompt

    cd "${1}"

    local allAlone='[[:alnum:]](<|>)$'

    local status=$(__git_ps1)

    local unsta='\u25cb' # ○
    local uncom='\u25cf' # ●
    local untra='\u25cc' # ◌
    local s_ahead='\u25b8' # ▸
    local s_behind='\u25c2' # ◂
    local s_even='' # '\u25b4' # ▴

    # remove the surrounding parens
    status=${status:2:$((${#status} - 3))}

    if [ -n "${status}" ]; then
        if $USE_SYMBOLS; then
            if [[ ${status} =~ $allAlone ]]; then
                local sym=${status:$(( ${#status} - 1 ))}
                status="${status::-1} ${sym}"
            fi
            status=${status/\*/${unsta}}
            status=${status/\+/${uncom}}
            status=${status/\%/${untra}}

            status=${status/\>/${s_ahead}}
            status=${status/\</${s_behind}}
            status=${status/\=/${s_even}}
        fi

        echo -ne "${status}"
    fi

    cd - > /dev/null
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
    local repoLen=$(getRepositoryNameLength)
    sourceGitShPrompt

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
    echo "MY_REPOSITORIES empty, nothing to do"
    exit 0
fi

repos=(${MY_REPOSITORIES//;/ })

if [ "${1}" = "update" ]; then
    sleep 10
    updateAll
fi

showAll
# vim: ft=sh fdm=marker foldlevel=0
