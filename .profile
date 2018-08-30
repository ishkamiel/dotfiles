# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4

export DOTFILES=${HOME}/.dotfiles

# This is ugly, but wil perhaps prevent clashes with bash-it...
if !  command -v exa >/dev/null 2>&1; then
    . ${DOTFILES}/lib/functions.sh/pathmunge.sh
    INCLUDE_pathmunge=true
fi

pathmunge "${HOME}/bin"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

# Load Ingel SGX SDK environment
[ -e /opt/intel/sgxsdk/environment ] && . /opt/intel/sgxsdk/environment

if $INCLUDE_pathmunge; then
    unset -f pathmunge
    unset INCLUDE_pathmunge
fi

setup_temp() {
    dir=$1
    hdir=$2

    [ -e "$dir" ] || mkdir "$dir"
    [ -e "$hdir" ] || ln -s "$dir" "$hdir"
    [ -e "$dir/Downloads" ] || mkdir "$dir/Downloads"
    [ -e "$dir/vimbackup" ] || mkdir "$dir/vimbackup"
}

if [ -e "/dev/shm" ]; then
    setup_temp "/dev/shm/${USER}-tmp" "${HOME}/tmp"
fi
