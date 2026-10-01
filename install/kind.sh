#!/usr/bin/env bash
set -euo pipefail

KIND_VERSION="0.33.0"
INSTALL_DIR="/usr/local/bin"

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

# ---- helpers ---------------------------------------------------------------

info() { echo "==> $*"; }
err() {
	echo "==> ERROR: $*" >&2
	exit 1
}

cleanup() {
	[[ -n "${TMPDIR:-}" ]] && rm -rf "$TMPDIR" 2>/dev/null || true
}
trap cleanup EXIT

# ---- platform detection ----------------------------------------------------

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$arch" in
x86_64) arch="amd64" ;;
aarch64 | arm64) arch="arm64" ;;
*) err "Unsupported architecture: $arch" ;;
esac

case "$os" in
linux | darwin) ;;
*) err "Unsupported OS: $os" ;;
esac

# ---- already installed? ----------------------------------------------------

if command -v kind &>/dev/null; then
	installed="$(kind version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || true)"
	if [[ "$installed" == "$KIND_VERSION" ]]; then
		info "kind $installed already installed at $(command -v kind)"
		exit 0
	fi
	info "kind ${installed:-unknown} found, upgrading to $KIND_VERSION"
fi

# ---- download & install ----------------------------------------------------

TMPDIR="$(mktemp -d)"
url="https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-${os}-${arch}"

info "Downloading kind $KIND_VERSION ($os/$arch)..."
curl -fsSL "$url" -o "$TMPDIR/kind"

info "Installing to $INSTALL_DIR/kind..."
sudo install -m 0755 "$TMPDIR/kind" "$INSTALL_DIR/kind"

installed="$(kind version 2>/dev/null | awk '{print $2}' | sed 's/^v//' || true)"
info "kind ${installed:-unknown} installed at $INSTALL_DIR/kind"
