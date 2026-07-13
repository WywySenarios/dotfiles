#!/usr/bin/env bash
# Kubernetes APT repository
set -euo pipefail

KEYRING="/usr/share/keyrings/kubernetes-keyring.gpg"

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key" | sudo gpg --dearmor --yes -o "$KEYRING"

echo "deb [signed-by=$KEYRING] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" |
	sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null

sudo apt update
