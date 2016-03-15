#! /bin/sh

conky -c ${HOME}/.conky/configs/clock
conky -c ${HOME}/.conky/configs/repo_status
conky -c ${HOME}/.conky/configs/rss_feeds
conky -c ${HOME}/.conky/configs/system
conky -c ${HOME}/.conky/configs/cpu
conky -c ${HOME}/.conky/configs/ram
conky -c ${HOME}/.conky/configs/files_$(hostname)

#conky -c ${DOTFILES_HOME}/.conky/default
