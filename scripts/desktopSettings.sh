#!/usr/bin/env bash

if command -v gsettings >/dev/null 2>&1 && command -v dconf >/dev/null 2>&1
then
    # Disable desktop icons
    dconf write /org/gnome/desktop/background/show-desktop-icons false

    # Auto-hide Ubuntu dock (under gnome-shell)
    dconf write /org/gnome/shell/extensions/dash-to-dock/dock-fixed false

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
