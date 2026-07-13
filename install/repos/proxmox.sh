#!/usr/bin/env bash
# Proxmox VE APT repository (no-subscription)
set -euo pipefail

DISTRO="$(lsb_release -cs 2>/dev/null || echo bookworm)"
KEYRING="/usr/share/keyrings/proxmox-keyring.gpg"

curl -fsSL "https://enterprise.proxmox.com/debian/proxmox-release-${DISTRO}.gpg" |
	sudo gpg --dearmor --yes -o "$KEYRING"

echo "deb [signed-by=$KEYRING] http://download.proxmox.com/debian/pve $DISTRO pve-no-subscription" |
	sudo tee /etc/apt/sources.list.d/proxmox.list >/dev/null

sudo apt update
