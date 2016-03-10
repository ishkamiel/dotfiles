#! /bin/sh
#
# heroku.sh
# Copyright (C) 2016 ishkamiel <ishkamiel@thigreal>
#
# Distributed under terms of the MIT license.
#

PATH_HEROKU="/usr/local/heroku/bin"
if [ -e "$PATH_HEROKU" ]; then AddToPath "$PATH_HEROKU"; fi
