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

function say_ask 
{
    local __retval=$1
    local retval
    echo -en "${COLOR_ASK}"
    read -p "$2 (y/[n])" retval;
    echo -en "${COLOR_RES}"
    eval $__retval="'$retval'"
}

IPACKAGES=()

for var in "${PACKAGES[@]}"
do
    if [ ! -f ${INSTALL_HISTORY} ]; then
        IPACKAGES+=(${var})
    elif [ $(grep -c ^${var}$ ${INSTALL_HISTORY}) -eq 0 ]; then
        IPACKAGES+=(${var})
    fi
done

if [ ! ${#IPACKAGES[@]} -eq 0 ]; then

    if [ ${ASK} ]; then 
        say_info "Installing stuff for ${PACKAGE_DESCRIPTTION}:\n${IPACKAGES[*]}\nAre you sure?"
        say_ask yn ""
    else
        yn='y'
    fi

    case $yn in
        [Yy]*) 
            # if [ ${ASK} ]; then 
            #     say_do "Okay, scheduling apt-get installations..."
            # else
            #     say_do "Scheduling aptitude installation of: ${IPACKAGES[*]}"
            # fi

            for var in "${IPACKAGES[@]}"
            do
                printf "%s\n" "${var}" >> "${INSTALL_SCHEDULE}"
            done
            ;;
        [Nn]*) 
            # say_info "Okay, skipping installation..."
            ;;
    esac
fi

