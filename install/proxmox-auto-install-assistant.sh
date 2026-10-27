#!/usr/bin/env bash
# Install proxmox-auto-install-assistant from the Proxmox VE repository.
set -euo pipefail

KEY_URL="https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg"
KEY_SHA256="136673be77aba35dcce385b28737689ad64fd785a797e57897589aed08db6e45"
KEYRING="/etc/apt/keyrings/proxmox-archive-keyring.gpg"
SOURCES="/etc/apt/sources.list.d/pve-install-repo.sources"
LEGACY_SOURCES="/etc/apt/sources.list.d/pve-install-repo.list"

info() { echo "==> $*"; }
err() {
	echo "==> ERROR: $*" >&2
	exit 1
}

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
[[ "$codename" == "trixie" ]] ||
	err "this script targets Debian 13 (trixie); detected '${codename:-unknown}'"

arch="$(dpkg --print-architecture)"
[[ "$arch" == "amd64" ]] ||
	err "the Proxmox VE repository only provides amd64 packages; detected $arch"

command -v curl &>/dev/null || err "'curl' is required but not installed"

# A bookworm-era source file would compete with the trixie one. Keep a backup
# so the old file is recoverable.
if [[ -e "$LEGACY_SOURCES" ]]; then
	info "Backing up legacy $LEGACY_SOURCES to $LEGACY_SOURCES.bak"
	sudo mv "$LEGACY_SOURCES" "$LEGACY_SOURCES.bak"
fi

# ---- Proxmox archive keyring ----------------------------------------------
info "Downloading the Proxmox archive keyring..."
tmp_key="$(mktemp)"
trap 'rm -f "$tmp_key"' EXIT

curl -fsSL "$KEY_URL" -o "$tmp_key"
printf '%s  %s\n' "$KEY_SHA256" "$tmp_key" | sha256sum --check --status ||
	err "the downloaded Proxmox keyring does not match the pinned SHA-256"

sudo install -D -m 0644 "$tmp_key" "$KEYRING"

# ---- Repository -----------------------------------------------------------
info "Adding the Proxmox VE trixie repository..."
sudo tee "$SOURCES" >/dev/null <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Architectures: amd64
Signed-By: $KEYRING
EOF

# ---- Install --------------------------------------------------------------
info "Installing proxmox-auto-install-assistant..."
sudo apt-get update
sudo apt-get install -y proxmox-auto-install-assistant

command -v proxmox-auto-install-assistant &>/dev/null ||
	err "installation finished but proxmox-auto-install-assistant is not in PATH"

info "Installed $(proxmox-auto-install-assistant --version)"
