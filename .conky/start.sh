#!/bin/bash

CONKY_LOG="${TMPDIR}/log/conky"
CONF_DIR="${HOME}/.conky/configs"
CONFIGS=(
clock
repo
rss_feeds
system
cpu
ram
files
)

# create the log directory unless it exists
[ -n "${CONKY_LOG}" ] && mkdir -p ${CONKY_LOG}

h=$(hostname)
for c in "${CONFIGS[@]}"; do
    fn="${CONF_DIR}/${c}"

    [ -e "${fn}_${h}" ] && fn="${fn}_${h}"

    echo "starting $fn"
    if [ -z "${CONKY_LOG}" ]; then
        conky -c $fn
    else
        conky -c $fn &> ${CONKY_LOG}/${c}.log
    fi
done
