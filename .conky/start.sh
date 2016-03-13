#! /bin/sh

conky -c ${DOTFILES_HOME}/.conky/configs/clock
conky -c ${DOTFILES_HOME}/.conky/configs/repo_status
conky -c ${DOTFILES_HOME}/.conky/configs/rss_feeds
conky -c ${DOTFILES_HOME}/.conky/configs/system
conky -c ${DOTFILES_HOME}/.conky/configs/cpu
conky -c ${DOTFILES_HOME}/.conky/configs/ram
conky -c ${DOTFILES_HOME}/.conky/configs/files

#conky -c ${DOTFILES_HOME}/.conky/default
