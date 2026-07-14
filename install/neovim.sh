#!/usr/bin/env bash
# install/neovim.sh — Neovim + NvChad config
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "sudo is required." >&2
	exit 1
fi

# 1. Install neovim
sudo apt-get install -y neovim

# 2. Clone NvChad starter as ~/.config/nvim/
NVIM_CONFIG="$HOME/.config/nvim"

if [ ! -d "$NVIM_CONFIG" ]; then
	echo "==> Cloning NvChad starter to $NVIM_CONFIG..."
	git clone --depth=1 https://github.com/NvChad/starter "$NVIM_CONFIG"
else
	echo "==> NeoVim configuration already present. NvChad starter installation will be skipped."
fi

echo "==> Done! Run nvim to let lazy.nvim finish the setup."
