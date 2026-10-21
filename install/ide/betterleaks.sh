#!/usr/bin/env bash
# Environment:
#   BETTERLEAKS_VERSION   version to install (default: v1.9.0)
#   INSTALL_DIR           install destination (default: /usr/local/bin)

set -euo pipefail

BETTERLEAKS_VERSION="${BETTERLEAKS_VERSION:-v1.9.0}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
MODULE="github.com/betterleaks/betterleaks"

# ---- helpers ---------------------------------------------------------------

info() { echo "==> $*"; }
err() {
	echo "==> ERROR: $*" >&2
	exit 1
}

cleanup() {
	[[ -n "${TMPDIR:-}" ]] && rm -rf "$TMPDIR" 2>/dev/null || true
}

# ---- input validation ------------------------------------------------------

# The version is interpolated into a Go module query.
# Restrict it to release tags so a bad value cannot select an arbitrary module or revision.
if [[ ! "$BETTERLEAKS_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
	err "BETTERLEAKS_VERSION must be a release tag like v1.9.0 (got: $BETTERLEAKS_VERSION)"
fi

[[ -n "$INSTALL_DIR" ]] || err "INSTALL_DIR must not be empty"

command -v go &>/dev/null || err "go is not installed — install it before running this script"

if [[ ! -d "$INSTALL_DIR" ]]; then
	err "INSTALL_DIR does not exist: $INSTALL_DIR"
fi

use_sudo=""
if [[ ! -w "$INSTALL_DIR" ]]; then
	command -v sudo &>/dev/null || err "sudo is required to write to $INSTALL_DIR"
	use_sudo="sudo"
fi

# ---- already installed? ----------------------------------------------------

installed_version=""
if command -v betterleaks &>/dev/null; then
	installed_version="$(betterleaks version 2>/dev/null | head -n1 || true)"
fi

# Accept both "1.9.0" and "v1.9.0" because the binary may print either.
if [[ "$installed_version" == "${BETTERLEAKS_VERSION#v}" || "$installed_version" == "$BETTERLEAKS_VERSION" ]]; then
	info "betterleaks $installed_version already installed at $(command -v betterleaks)"
else
	if [[ -n "$installed_version" ]]; then
		info "betterleaks ${installed_version} found, upgrading to $BETTERLEAKS_VERSION"
	else
		info "Installing betterleaks $BETTERLEAKS_VERSION with go install..."
	fi

	TMPDIR="$(mktemp -d)"
	trap cleanup EXIT

	GOBIN="$TMPDIR" go install "${MODULE}@${BETTERLEAKS_VERSION}"

	info "Installing to $INSTALL_DIR/betterleaks..."
	if [[ -n "$use_sudo" ]]; then
		sudo install -m 0755 "$TMPDIR/betterleaks" "$INSTALL_DIR/betterleaks"
	else
		install -m 0755 "$TMPDIR/betterleaks" "$INSTALL_DIR/betterleaks"
	fi

	installed_version="$(betterleaks version 2>/dev/null | head -n1 || true)"
	info "betterleaks ${installed_version:-unknown} installed at $INSTALL_DIR/betterleaks"
fi
