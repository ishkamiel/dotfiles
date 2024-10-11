#!/usr/bin/env bash
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

set -euo pipefail

# Parse options
DRY_RUN=false
while getopts "n" opt; do
  case $opt in
    n)
      DRY_RUN=true
      ;;
    *)
      echo "Usage: $0 [-n]"
      exit 1
      ;;
  esac
done

# Function to execute or echo commands based on dry-run flag
run_command() {
  echo "$*"
  if [ "$DRY_RUN" = false ]; then
    eval "$*"
  fi
}

# Function to install cargo package if not installed
cargo_install_if_not() {
  local pkg="$1"
  if ! cargo install --list | grep -q "^$pkg "; then
      run_command "cargo install --locked $pkg"
  fi
}

# Check if rustup is installed
if ! command -v rustup &> /dev/null; then
    # Install rustup using the system package manager
    run_command "sudo apt update"
    run_command "sudo apt install -y rustup"
fi

if rustup toolchain list | grep -q "stable.*(default)"; then
    run_command "rustup update stable"
else
    run_command "rustup install stable"
    run_command "rustup default stable"
fi


# Install cargo-update to manage package updates
cargo_install_if_not "cargo-update"

# Update all cargo packages
run_command "cargo install-update -a -q"

# Read cargo packages from file and install them line by line
input_file="$DOTFILES/misc/cargo_packages.txt"
if [[ -f "$input_file" ]]; then
    while IFS= read -r package; do
        if [[ -n "$package" && ! "$package" =~ ^# ]]; then
            cargo_install_if_not "$package"
        fi
    done < "$input_file"
else
    echo "File $input_file not found!!!"
fi
