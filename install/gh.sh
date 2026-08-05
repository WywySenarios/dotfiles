#!/usr/bin/env bash
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

if command -v gh &>/dev/null; then
	echo "==> GitHub CLI already installed at $(command -v gh)."
	exit 0
fi

echo "==> Installing GitHub CLI repository prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl

echo "==> Adding GitHub CLI signing key..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
	sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "==> Adding GitHub CLI APT repository..."
arch="$(dpkg --print-architecture)"
echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |
	sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

echo "==> Installing GitHub CLI..."
sudo apt-get update
sudo apt-get install -y gh

echo "==> Installed $(gh --version)"
