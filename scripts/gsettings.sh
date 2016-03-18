#!/bin/sh

# Fix desktop background and right-click
gsettings set org.gnome.settings-daemon.plugins.background active false
# Disable annoying search on type thing
gsettings set org.gnome.nautilus.preferences enable-interactive-search false
# Enable delete contect menu action
gsettings set org.gnome.nautilus.preferences enable-delete true

# Caps lock to escape
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
