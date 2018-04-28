#!/usr/bin/env bash

[[ -z "${LIB_CHECKS_SH}" ]] && source "${DOTFILES}/lib/checks.sh"

if command -v gsettings >/dev/null 2>&1 && command -v dconf >/dev/null 2>&1
then
    # Set the defaul monospace font
    if is_package_installed "fonts-hack-otf"; then
        dconf write /org/gnome/desktop/interface/monospace-font-name "'Hack 12'"
    fi

    # Disable desktop icons
    dconf write /org/gnome/desktop/background/show-desktop-icons false

    # Move titlebar buttons to the left
    dconf write /org/gnome/desktop/wm/preferences/button-layout "'close,minimize,maximize:'"

    # Make ALT be the window action key (instead of SUPER)
    dconf write /org/gnome/desktop/wm/preferences/mouse-button-modifier "'<Alt>'"

    # Auto-hide Ubuntu dock (under gnome-shell)
    dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false

    # Make workspaces span all displays
    dconf write /org/gnome/mutter/workspaces-only-on-primary false

    # Fix desktop background and right-click
    gsettings set org.gnome.settings-daemon.plugins.background active true
    # Disable annoying search on type thing (FIXME: no longer working?)
    gsettings set org.gnome.nautilus.preferences enable-interactive-search false
    # Enable delete contect menu action (FIXME: no longer working?)
    gsettings set org.gnome.nautilus.preferences enable-delete true
    # Don't autopopup nautilus window on USB (or phone) plugins
    gsettings set org.gnome.desktop.media-handling automount-open false

    # Caps lock to escape
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

else
    >&2 echo "Skipping desktop setup, cannot find gsettings and dconf"
fi
