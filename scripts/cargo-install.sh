#!/usr/bin/env bash

#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

# TODO: Check how to install rustup
# TODO: Update cargo
# TODO: Add to main script

rustup update

cargo install --locked cargo-update
cargo install --locked du-dust
cargo install --locked eza
cargo install --locked zellij

cargo insta-update --locked --all
