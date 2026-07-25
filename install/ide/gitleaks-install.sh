#!/usr/bin/env bash
# gitleaks-install.sh — Install gitleaks binary and optional pre-commit hook.
#
# Usage:
#   bash ~/.local/bin/gitleaks-install.sh              # install binary only
#   bash ~/.local/bin/gitleaks-install.sh --hooks       # also write pre-commit hook
#                                                        into the current repo
#
# Environment:
#   GITLEAKS_VERSION   version to install (default: 8.30.1)

set -euo pipefail

GITLEAKS_VERSION="${GITLEAKS_VERSION:-8.30.1}"
INSTALL_DIR="/usr/local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- helpers ---------------------------------------------------------------

info() { echo "==> $*"; }
warn() { echo "==> WARNING: $*" >&2; }
err() {
	echo "==> ERROR: $*" >&2
	exit 1
}

cleanup() {
	[[ -n "${TMPDIR:-}" ]] && rm -rf "$TMPDIR" 2>/dev/null || true
}

# ---- platform detection ----------------------------------------------------

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"

case "$arch" in
x86_64) arch="x64" ;;
aarch64) arch="arm64" ;;
armv7l) arch="armv7" ;;
*) err "Unsupported architecture: $arch" ;;
esac

case "$os" in
linux | darwin) ;;
*) err "Unsupported OS: $os" ;;
esac

# ---- download & install ----------------------------------------------------

tarball="gitleaks_${GITLEAKS_VERSION}_${os}_${arch}.tar.gz"
url="https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/${tarball}"

if command -v gitleaks &>/dev/null; then
	installed="$(gitleaks --version 2>/dev/null || true)"
	if [[ "$installed" == "$GITLEAKS_VERSION" ]]; then
		info "gitleaks $installed already installed at $(command -v gitleaks)"
	else
		info "gitleaks $installed found, upgrading to $GITLEAKS_VERSION"
	fi
fi

TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

info "Downloading gitleaks $GITLEAKS_VERSION ($os/$arch)..."
curl -fsSL "$url" -o "$tarball"

info "Extracting..."
tar -xzf "$tarball"

info "Installing to $INSTALL_DIR/gitleaks..."
sudo install -m 0755 gitleaks "$INSTALL_DIR/gitleaks"

cleanup

trap cleanup EXIT
installed="$(gitleaks --version 2>/dev/null || true)"
info "gitleaks $installed installed at $INSTALL_DIR/gitleaks"

# ---- optional pre-commit hook ----------------------------------------------

if [[ "${1:-}" == "--hooks" ]]; then
	repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
	if [[ -z "$repo_root" ]]; then
		warn "Not inside a git repository — skipping pre-commit hook"
		exit 0
	fi

	hook_file="$repo_root/.git/hooks/pre-commit"
	if [[ -f "$hook_file" ]]; then
		info "Pre-commit hook already exists at $hook_file — skipping"
	else
		info "Writing pre-commit hook to $hook_file..."
		cat >"$hook_file" <<'HOOK'
#!/bin/bash
# Gitleaks pre-commit hook — blocks commits containing secrets.
set -euo pipefail
exec gitleaks protect --staged --verbose
HOOK
		chmod +x "$hook_file"
		info "Pre-commit hook installed"
	fi
fi
