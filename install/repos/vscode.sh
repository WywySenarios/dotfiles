#!/usr/bin/env bash
# VS Code APT repository
set -euo pipefail

ARCH="$(dpkg --print-architecture)"
KEYRING="/usr/share/keyrings/vscode-keyring.gpg"

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | sudo gpg --dearmor --yes -o "$KEYRING"

echo "deb [arch=$ARCH signed-by=$KEYRING] https://packages.microsoft.com/repos/code stable main" |
	sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

sudo apt update
