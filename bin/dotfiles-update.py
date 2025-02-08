#! /usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Author: Hans Liljestrand <hans@liljestrand.dev>
# Copyright (C) 2024-2025 Hans Liljestrand <hans@liljestrand.dev>
#
# Distributed under terms of the MIT license.

import os
import subprocess
import sys
import shutil
from pathlib import Path
import argparse
from unittest import runner

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "ishlib" / "src"))
from pyishlib.installer_config import InstallerConfigJSON
from pyishlib.installer import Installer
from pyishlib.command_runner import CommandRunner


class Main:
    SCRIPTS: list[str] = [
        "install_cargo_pkgs.sh",
        "install_fzf.sh",
        "install_oh_my_zsh.sh",
        "install_vim_plugins.sh",
    ]

    def __init__(self) -> None:
        self.dotfiles_path: Path = Path(__file__).resolve().parent.parent

        parser = argparse.ArgumentParser(description="Managing dotfiles")
        parser.add_argument("-n", "--dry-run", action="store_true")
        parser.add_argument("-v", "--verbose", action="store_true")
        parser.add_argument("-d", "--debug", action="store_true")
        self.args = parser.parse_args()

        self.runner = CommandRunner(args=self.args)

    def say_step(self, step) -> None:
        print(f"=== {step}")

    def update_submodules(self):
        self.say_step("Updating submodules")
        self.runner.run(
            [
                "git",
                "-C",
                self.dotfiles_path,
                "submodule",
                "update",
                "--init",
                "--recursive",
            ],
            check=True,
        )

    def stow_packages(self):
        self.say_step("Stowing packages")
        stow_pkg_dir = self.dotfiles_path / "stow_pkgs"

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
                [
                    "git",
                    "-C",
                    str(self.dotfiles_path),
                    "checkout",
                    f"stow_pkgs/{pkg.name}",
                ],
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
        for s in self.SCRIPTS:
            script: Path = self.dotfiles_path / "scripts" / s
            self.say_step(f"Running {script}")
            self.runner.run([str(script)], check=True)

    def install_packages(self) -> None:
        self.say_step(f"Installing missing packages")
        installer_config: InstallerConfigJSON = InstallerConfigJSON(
            self.dotfiles_path / "packages_to_install.json"
        )
        installer: Installer = Installer(runner=self.runner)
        installer.install_all(installer_config.get_pkgs())

    def run(self) -> None:
        self.update_submodules()
        self.install_packages()
        self.stow_packages()
        self.run_scripts()


if __name__ == "__main__":
    Main().run()
