#!/usr/bin/env bash
# Docker APT repository
set -euo pipefail

DISTRO="$(lsb_release -cs 2>/dev/null || echo bookworm)"
ARCH="$(dpkg --print-architecture)"
KEYRING="/usr/share/keyrings/docker-keyring.gpg"

curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo gpg --dearmor --yes -o "$KEYRING"

echo "deb [signed-by=$KEYRING] https://download.docker.com/linux/ubuntu $DISTRO stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update
