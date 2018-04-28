#!/bin/sh
#
# Based on https://github.com/Bash-it/bash-it

pathmunge () {
    if [ -e "$1" ]; then
        if echo "$PATH" | grep -E -q "(^|:)$1($|:)"; then
            if [ "$2" = "after" ] ; then
                export PATH=$PATH:$1
            else
                export PATH=$1:$PATH
            fi
        fi
    fi
}
