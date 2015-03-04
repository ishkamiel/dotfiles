COLOR_RES='\033[0m'
COLOR_DO='\033[0;31m'
COLOR_INFO='\033[0;32m'
COLOR_ASK='\033[0;33m'

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

if [ ${ASK} ]; then 
    say_info "Installing stuff for ${PACKAGE_DESCRIPTTION}:\n${PACKAGES[*]}\nAre you sure?"
    say_ask yn ""
else
    yn='y'
fi
case $yn in
    [Yy]*) 
        say_do "Running aptitude..."
        sudo aptitude install ${PACKAGES[*]}
        ;;
    [Nn]*) 
        #say_info "Okay, skipping installation..."
        ;;
esac
