#! /usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

import os
import subprocess
import sys
import shutil
from pathlib import Path
import argparse


def say_step(step):
    print(f"=== {step}")


def is_missing(command):
    return not shutil.which(command)


class CommandRunner:
    def __init__(self, dry_run=False):
        self.dry_run = dry_run

    def run(self, command, **kwargs):
        command = [str(c) for c in command]
        print(f"{' '.join(command)}")
        if not self.dry_run:
            return subprocess.run(command, **kwargs)
        else:
            return subprocess.CompletedProcess(args=command, returncode=0)

    def chdir(self, path):
        print(f"chdir {path}")
        if not self.dry_run:
            os.chdir(path)

    def unlink(self, path):
        print(f"unlink {path}")
        if not self.dry_run:
            path.unlink()


class Main:
    def __init__(self):
        self.needed_cmds = ["stow", "git"]

        self.dotfiles_path = Path(__file__).resolve().parent.parent
        self.dotfiles = Path(os.getenv("DOTFILES", str(self.dotfiles_path)))

        parser = argparse.ArgumentParser(description="Managing dotfiles")
        parser.add_argument("-n", "--dry-run", action="store_true")
        self.args = parser.parse_args()

        self.runner = CommandRunner(dry_run=self.args.dry_run)

    def run_script(self, script):
        script_path = self.dotfiles / "scripts" / script
        say_step(f"Running {script_path}")
        self.runner.run([str(script_path)], check=True)

    def check_needed_cmds(self):
        need_to_install = [cmd for cmd in self.needed_cmds if is_missing(cmd)]
        if need_to_install:
            say_step(f"Need to install: {need_to_install}")
            print(f"sudo apt-get install -y {' '.join(need_to_install)}")
            input("Press any key to continue or Ctrl+C to abort...")
            self.runner.run(
                ["sudo", "apt", "install", "-y"] + need_to_install, check=True
            )

    def update_submodules(self):
        say_step("Updating submodules")
        self.runner.chdir(self.dotfiles)
        self.runner.run(
            [
                "git",
                "-C",
                self.dotfiles,
                "submodule",
                "update",
                "--init",
                "--recursive",
            ],
            check=True,
        )

    def stow_packages(self):
        say_step("Stowing packages")
        stow_pkg_dir = self.dotfiles / "stow_pkgs"

        for pkg in stow_pkg_dir.iterdir():

            # Just try to adopt all the files
            stow_args = [
                "-v",
                "--adopt",
                "-d",
                stow_pkg_dir,
                "-t",
                Path.home(),
                pkg.name,
            ]
            result = self.runner.run(
                ["stow"] + stow_args, capture_output=True, text=True
            )

            # But may need to remove old symlinks if file was managed otherwise
            if result.returncode != 0:
                lines = result.stderr.splitlines()
                bad = [l.split()[-1] for l in lines if "not owned by stow:" in l]
                for file in bad:
                    file_path = Path.home() / file
                    if file_path.is_symlink() and not file_path.exists():
                        print(f"Removing dead link: {file_path}")
                        file_path.unlink()

            # Need to restore the original files since adopt may have ovrwritten them
            self.runner.run(
                ["git", "-C", str(self.dotfiles), "checkout", f"stow_pkgs/{pkg.name}"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            # Now we can finally update the pkg symlinks
            stow_args = ["-R", "-d", stow_pkg_dir, "-t", str(Path.home()), pkg.name]
            result = self.runner.run(
                ["stow"] + stow_args, capture_output=True, text=True
            )
            # Filter the output to avoid annoying stow BUG m message
            # print(result.stderr.replace('BUG in find_stowed_path', ''))

    def run_scripts(self):
        scripts = [
            "install_apt_pkgs.sh",
            "install_cargo_pkgs.sh",
            "install_fzf.sh",
            "install_oh_my_zsh.sh",
            "install_vim_plugins.sh",
        ]
        for script in scripts:
            self.run_script(script)

    def run(self):
        print(f"DOTFILES: {self.dotfiles}")
        assert self.dotfiles == self.dotfiles_path
        self.check_needed_cmds()
        self.update_submodules()
        self.stow_packages()
        # self.restow()
        self.run_scripts()


if __name__ == "__main__":
    main = Main()
    main.run()
