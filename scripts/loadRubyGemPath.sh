#! /bin/sh

# This is a very simplistic loader that simply looks for a ~/.gem/ruby directory, tries
# to determine the latest ruby version and then addsa a path to it.

gempath="${HOME}/.gem/ruby"
if [ -e "${gempath}" ]; then
    ruby_version=$(ls ${gempath} | sort | tail -n 1);
    gem_bin="${gempath}/${ruby_version}/bin"
    AddToPath "${gem_bin}"
fi
