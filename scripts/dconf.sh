#!/bin/sh

# Fix desktop background and right-click
gsettings set org.gnome.settings-daemon.plugins.background active true

# Caps lock to escape
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"

