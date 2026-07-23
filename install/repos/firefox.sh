#!/usr/bin/env bash
# Mozilla Firefox APT repository (deb822 format)
set -euo pipefail

KEYRING="/usr/share/keyrings/firefox-keyring.gpg"

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

curl -fsSL "https://packages.mozilla.org/apt/repo-signing-key.gpg" | sudo gpg --dearmor --yes -o "$KEYRING"

cat <<EOF | sudo tee /etc/apt/sources.list.d/firefox.sources >/dev/null
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: $KEYRING
EOF

sudo apt update
