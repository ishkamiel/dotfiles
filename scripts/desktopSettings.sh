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

    # Hide gnome-terminal menu bar
    dconf write /org/gnome/terminal/legacy/default-show-menubar false

    # Disable animations in Gnome
    gsettings set org.gnome.desktop.interface enable-animations false

    # Enable hot-corner for activities overview
    gsettings set org.gnome.desktop.interface enable-hot-corners true

    # Show date in top bar
    gsettings set org.gnome.desktop.interface clock-show-date true

    # Show weekdays in calendar
    gsettings set org.gnome.desktop.calendar show-weekdate true

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

    # Enable fractional scaling values
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"

    # Disable desktop icons via the Ubuntu Gnome extension
    gsettings set org.gnome.shell.extensions.desktop-icons  show-home false
    gsettings set org.gnome.shell.extensions.desktop-icons  show-trash false

    # Disable app name in no-title-bar extension
    dconf write /org/gnome/shell/extensions/no-title-bar/change-appmenu false
    # Don't put buttons in the titlebar
    dconf write /org/gnome/shell/extensions/no-title-bar/button-position "'hidden'"

else
    >&2 echo "Skipping desktop setup, cannot find gsettings and dconf"
fi
