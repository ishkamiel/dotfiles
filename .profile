# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4

export DOTFILES=${HOME}/.dotfiles
[ -e "${HOME}/bin" ] && export PATH="${HOME}/bin:${PATH}"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

# Load Intel SGX SDK environment, if available
# shellcheck disable=SC1091
[ -e /opt/intel/sgxsdk/environment ] && . /opt/intel/sgxsdk/environment

if [ -e "/dev/shm" ]; then
    dir="/dev/shm/${USER}-tmp"
    hdir="${HOME}/tmp"

    [ -e "$dir" ] || mkdir "$dir"
    [ -e "$hdir" ] || ln -s "$dir" "$hdir"
    [ -e "$dir/Downloads" ] || mkdir "$dir/Downloads"
    [ -e "$dir/vimbackup" ] || mkdir "$dir/vimbackup"
fi

# shellcheck disable=SC1090
[ -e "${HOME}/.profile_local" ] && . "${HOME}/.profile_local"
