#!/usr/bin/env bash
# install.sh — install packages listed in packages.d/*.txt files
#
# Usage:
#   ./install.sh apt.txt npm.txt              # apt install (default)
#   ./install.sh --npm npm.txt                # npm install -g
#   ./install.sh --pipx pipx.txt              # pipx install
#   ./install.sh --pip pip.txt                # pip install
#   ./install.sh --go go.txt                  # go get
#
# Each argument is a .txt file path relative to the directory containing this
# script.  Only the first non-comment word on each line is used as the package
# name (inline comments and blank lines are ignored).

set -euo pipefail

SELF="$(cd "$(dirname "$0")" && pwd)"
MODE="apt"

# --- parse flags ---
case "${1:-}" in
--npm)
	MODE="npm"
	shift
	;;
--pipx)
	MODE="pipx"
	shift
	;;
--pip)
	MODE="pip"
	shift
	;;
--go)
	MODE="go"
	shift
	;;
esac

if [ $# -eq 0 ]; then
	echo "Usage: $0 [--npm|--pipx|--pip|--go] <file.txt> [...]" >&2
	exit 1
fi

# --- collect package names ---
pkgs=()
for f in "$@"; do
	file="$SELF/$f"
	if [ ! -f "$file" ]; then
		echo "Error: file not found — $file" >&2
		exit 1
	fi
	while IFS= read -r name; do
		[ -n "$name" ] && pkgs+=("$name")
	done < <(awk '!/^#/ && !/^$/ {print $1}' "$file")
done

if [ ${#pkgs[@]} -eq 0 ]; then
	echo "No packages found in specified files." >&2
	exit 0
fi

echo "==> Packages to install: ${pkgs[*]}"

# --- install ---
case "$MODE" in
apt)
	echo "==> Installing ${#pkgs[@]} package(s) via apt..."
	set -x
	sudo apt install -y "${pkgs[@]}"
	set +x
	;;
npm)
	echo "==> Installing ${#pkgs[@]} package(s) via npm (global)..."
	set -x
	npm install -g "${pkgs[@]}"
	set +x
	;;
pipx)
	echo "==> Installing ${#pkgs[@]} package(s) via pipx..."
	for pkg in "${pkgs[@]}"; do
		set -x
		pipx install "$pkg"
		set +x
	done
	;;
pip)
	echo "==> Installing ${#pkgs[@]} package(s) via pip..."
	set -x
	pip install "${pkgs[@]}"
	set +x
	;;
go)
	echo "==> Installing ${#pkgs[@]} Go module(s)..."
	for pkg in "${pkgs[@]}"; do
		set -x
		go get "$pkg"
		set +x
	done
	;;
esac

echo "==> Done."
