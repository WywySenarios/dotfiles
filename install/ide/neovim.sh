#!/usr/bin/env bash
# install/ide/neovim/install.sh — Neovim + NvChad config
set -euo pipefail

GIT_USER="WywySenarios"

for arg in "$@"; do
	case "$arg" in
	--me)
		GIT_USER="$(git config user.name)"
		;;
	esac
done

# 1. Download and install latest neovim release to /opt
echo "==> Downloading latest neovim release..."
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

echo "==> Installing to /opt..."
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

rm -f nvim-linux-x86_64.tar.gz

mkdir -p "$HOME/.local/bin"
ln -sf /opt/nvim-linux-x86_64/bin/nvim "$HOME/.local/bin/nvim"

echo "==> nvim symlinked to $HOME/.local/bin/nvim"

# 2. Clone NvChad starter as ~/.config/nvim/
NVIM_CONFIG="$HOME/.config/nvim"

if [ ! -d "$NVIM_CONFIG" ]; then
	echo "==> Cloning nvchad-config from github.com/$GIT_USER/nvchad-config to $NVIM_CONFIG..."
	git clone --depth=1 "https://github.com/$GIT_USER/nvchad-config" "$NVIM_CONFIG"
else
	echo "==> NeoVim configuration already present. NvChad starter installation will be skipped."
fi

echo "==> Done! Run nvim to let lazy.nvim finish the setup. Make sure to install NerdFont as well."
