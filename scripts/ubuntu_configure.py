#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import sys
import shlex
from pathlib import Path
import argparse
from typing import NoReturn, Mapping, Any

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "ishlib" / "src"))
from pyishlib.installer_config import InstallerConfigJSON
from pyishlib.installer import Installer
from pyishlib.ish_comp import IshComp
from pyishlib.command_runner import CommandRunner

DCONF: Mapping[str, Any] = {
  'org/gnome/desktop/interface': {
    'monospace-font-name': 'Hack 12'
  },
  'org/gnome/desktop/background': {
    'show-desktop-icons': True
  },
  'org/gnome/mutter': {
    'dynamic-workspaces': False
  },
  'org/gnome/desktop/wm/preferences': {
    'num-workspaces': 4,
  },
  'org/gnome/shell/extensions/dash-to-dock': {
    # Auto-hide Ubuntu dock
    'dock-fixed': False,
    'isolate-workspaces': True
  },
  'org/gnome/shell/extensions/tiling-assistant': {
    'tiling-popup-all-workspace': False
  },
'org/gnome/desktop/sound': {
'event-sounds': False
},
}

GSETTINGS: Mapping[str, Any] = {
'org.gnome.desktop.interface': {
  'enable-animations': False,
  'enable-hot-corners': False,
},
'org.gnome.desktop.calendar': {
  'show-weekdate': True,
},
'org.gnome.desktop.input-sources': {
  'xkb-options': ["caps:escape"],
},
}

def format_key(value: Any) -> str:
  if isinstance(value, str):
    return shlex.quote(value)
  elif isinstance(value, bool): 
    return "true" if value else "false"
  elif isinstance(value, int):
    return str(value)
  elif isinstance(value, list):
    return f"[{', '.join([f'"{k}"' for k in map(format_key, value)])}]"
  else:
    raise ValueError(f"Unsupported value type: {type(value)}")

class Main(IshComp):
    def __init__(self) -> None:
        self.dotfiles_path: Path = Path(__file__).resolve().parent.parent

        parser = argparse.ArgumentParser(description="Managing dotfiles")
        parser.add_argument("-n", "--dry-run", action="store_true")
        parser.add_argument("-v", "--verbose", action="store_true")
        parser.add_argument("-d", "--debug", action="store_true")
        args = parser.parse_args()

        self.runner = CommandRunner(args=args)
        super().__init__(args=args)

    
    def run(self) -> None:
      # Check if we are running on Ubuntu and X11/Wayland

      if not self.runner.on_ubuntu_desktop():
        self.log.warn("Not in Ubuntu desktop session")
        sys.exit(1)
      
      self.log.info("Setting dconf options")

      for key, value in DCONF.items():
          for k, v in value.items():
            self.log.debug("Setting dconf key: %s/%s = %s", key, k, v)
            self.runner.run(['dconf', 'write', f'/{key}/{k}', format_key(v)])
      
      self.log.info("Setting gsettings options")

      for key, value in GSETTINGS.items():
        for k, v in value.items():
          self.log.debug("Setting gsettings key: %s/%s = %s", key, k, v)
          self.runner.run(['gsettings', 'set', key, k, format_key(v)])

if __name__ == "__main__":
    Main().run()
