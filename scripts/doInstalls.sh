#!/bin/bash

COLOR_RES='\033[0m'
COLOR_DO='\033[0;31m'
COLOR_INFO='\033[0;32m'
COLOR_ASK='\033[0;33m'

INSTALL_HISTORY=~/.pdDotfileAptH
INSTALL_SCHEDULE=~/.pdDotfileAptS

function say_do {
    echo -en "${COLOR_DO}$1${COLOR_RES}\n"
}

function say_info {
    echo -e "${COLOR_INFO}$1${COLOR_RES}"
}

if [ -e ${INSTALL_SCHEDULE} ]; then
    #PACKAGES=$(cat ${INSTALL_SCHEDULE} | tr "\\n" " ")
    IFS=" " read -a PACKAGES <<< $(cat ${INSTALL_SCHEDULE} | sort | tr "\\n" " ")
    rm ${INSTALL_SCHEDULE}

    if [ ${#PACKAGES[@]} -eq 0 ]; then
        say_info "Nothing to install..."
    else
        say_do "Running apt-get to install: ${PACKAGES[*]}"

        if sudo apt-get install ${PACKAGES[*]}; then 
            for var in "${PACKAGES[@]}"
            do
                printf "%s\n" "${var}" >> "${INSTALL_HISTORY}"
            done
        else
            say_do "INSTALL FAILED!"
            exit 1
        fi
    fi
fi
