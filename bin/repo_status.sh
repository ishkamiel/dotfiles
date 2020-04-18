#! /usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2020 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

repo_status() {
    local repo_base="$1"
    local repo_path="${repo_base}/.git"
    local ref
    local output
    local mode
    local dirty=' ●✚'
    local repo_symbol=''

    pushd "${repo_base}" > /dev/null || return 1

    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        echo "$repo_base no a Git repository!"
        return 2
    fi

    ref=$(git symbolic-ref HEAD 2> /dev/null)  || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -e "${repo_path}/BISECT_LOG" ]]
    then
        mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]
    then
        mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]
    then
        mode=" >R>"
    fi


    # repo_path="$(git rev-parse --is-inside-work-tree --git-dir | tail -n1)"
    # [ $? ] || return $?

    if output=$(git status --porcelain) && [ -z "$output" ]; then
        dirty='   '
    fi

    echo "${ref/refs\/heads\//$repo_symbol }${dirty}"

    # echo "${repo_symbol} ${repo_path} ${ref}${dirty}${mode}"
    popd > /dev/null || return 1
}

repo_status ~/d/llvm
repo_status ~/personal
repo_status ~/.dotfiles
repo_status ~/Downloads
