# vim: fdm=marker foldlevel=0 shiftwidth=4 tabstop=4

__prepend_to_PATH() {
    case ":$PATH:" in
        *:$1:*)
            # echo "$1 already in path, skipping"
            ;; # already in PATH, doing nothing
        *)
            # [ -e "$1" ] || echo "$1 not found, skipping"
            [ -e "$1" ] && export PATH="$1:${PATH}"
            ;;
    esac
}

__append_to_PATH() {
    case ":$PATH:" in
        *:$1:*)
            # echo "$1 already in path, skipping"
            ;; # already in PATH, doing nothing
        *)
            # [ -e "$1" ] || echo "$1 not found, skipping"
            [ -e "$1" ] && export PATH="${PATH}:$1"
            ;;
    esac
}

export DOTFILES="${HOME}/.dotfiles"
__prepend_to_PATH "${HOME}/bin"
__prepend_to_PATH "${HOME}/.local/bin"
__prepend_to_PATH "$HOME/.cargo/bin"
__prepend_to_PATH "$HOME/.emacs.d/bin"

# Fix for intellj IDEs: https://youtrack.jetbrains.com/issue/IDEA-78860
export IBUS_ENABLE_SYNC_MODE=1

# Load Intel SGX SDK environment, if available
# shellcheck disable=SC1091
[ -e /opt/intel/sgxsdk/environment ] && . /opt/intel/sgxsdk/environment

if [ -e "/dev/shm" ]; then
    dir="/dev/shm/${USER}-tmp"
    hdir="${HOME}/tmp"
    [ -e "$dir" ]  || mkdir "$dir"
    [ -e "$hdir" ] || ln -s "$dir" "$hdir"
fi

# shellcheck disable=SC1090 disable=SC1091
[ -e "${HOME}/.profile_local" ] && . "${HOME}/.profile_local"

# Load .Xresources if we have xrdb and it exists
command -v xrdb >/dev/null 2>&1 && \
    [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" != "tty" ] &&\
    [ -e "${HOME}/.Xresources" ] && xrdb -merge "${HOME}/.Xresources"

# Load cargo environment
# shellcheck disable=SC1091
[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

