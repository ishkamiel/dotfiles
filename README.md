# Dotfiles using chezmoi (for personal use)

```bash
#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/twpayne/chezmoi.git "${HOME}/opt/chezmoi"
cd "${HOME}/opt/chezmoi" || exit
git checkout e2e3d1d416604bfe97ff2abfd14d197b79359e5b
make -j$(nproc)" install-from-git-working-copy
```
