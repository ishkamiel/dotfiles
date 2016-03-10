#! /bin/sh
#
# ruby.sh
# Copyright (C) 2016 ishkamiel <ishkamiel@thigreal>
#
# Distributed under terms of the MIT license.
#



# NOTE: This very simply just takes the highest version path and adds that to $PATH
_RUBY_GEM_PATH="$HOME/.gem/ruby"
if [ -e "$_RUBY_GEM_PATH" ]; then
    _RUBY_VERSION=$(ls $_RUBY_GEM_PATH | sort | tail -n 1);
    _RUBY_PATH="$_RUBY_GEM_PATH/$_RUBY_VERSION/bin"

    if [ -e "$_RUBY_PATH" ]; then
        AddToPath $_RUBY_PATH
    fi
fi
