#!/usr/bin/env bash
# install/ide/vscode.sh — VS Code APT repository + binary install
set -euo pipefail

install_vscode() {
	if command -v code &>/dev/null; then
		echo "==> VS Code already installed. Skipping package install."
		return
	fi

	if ! command -v sudo &>/dev/null; then
		echo "This script assumes that sudo is available." >&2
		exit 1
	fi

	local arch keyring
	arch="$(dpkg --print-architecture)"
	keyring="/usr/share/keyrings/vscode-keyring.gpg"

	curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | sudo gpg --dearmor --yes -o "$keyring"

	echo "deb [arch=$arch signed-by=$keyring] https://packages.microsoft.com/repos/code stable main" |
		sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y code
}

install_vscode
