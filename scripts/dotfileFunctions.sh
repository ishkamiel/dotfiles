#! /bin/sh


dotfilesUpdate() {
    dotbot="${DOTFILES_HOME}/dotbot/bin/dotbot"

    if [ ! -e ${DOTFILES_CONFIG} ]; then
        echo "Cannot find dotfiles config: ${DOTFILES_CONFIG}"; return
    fi

    if [ ! -e ${dotbot} ]; then
        echo "Cannot find dotbot: ${dotbot}"; return;
    fi

    # git submodule update --init --recursive "${DIR}"
    "${dotbot}" -d "${DOTFILES_HOME}" -c "${DOTFILES_CONFIG}"
}

