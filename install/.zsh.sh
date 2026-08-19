#!/usr/bin/env bash
# install/.zsh.sh — deploy the zsh shell entry files into $HOME.
# Links ~/.zshrc and ~/.zprofile to the repo copies.
# Idempotent: existing non-symlinks are backed up to *.bak before linking.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Helper ──────────────────────────────────────────────────────────────────
ensure_parent_dir() {
	local d="$1"
	local parent
	parent="$(dirname "$d")"
	[ -d "$parent" ] || mkdir -p "$parent"
}

deploy_symlink() {
	local src="$1" dst="$2"
	if [ ! -e "$src" ]; then
		echo "==> SKIP  $src  (not found in repo)" >&2
		return
	fi
	ensure_parent_dir "$dst"
	if [ -e "$dst" ] && [ ! -L "$dst" ]; then
		echo "==> BACKUP  $dst → ${dst}.bak"
		mv "$dst" "${dst}.bak"
	elif [ -L "$dst" ]; then
		echo "==> REPLACE  $dst"
		rm -f "$dst"
	fi
	ln -sf "$src" "$dst"
	echo "==> LINK  $src → $dst"
}

# ── Deploy zsh entry files ─────────────────────────────────────────────────
deploy_symlink "$REPO/.zshrc" "$HOME/.zshrc"
deploy_symlink "$REPO/.zprofile" "$HOME/.zprofile"

echo ""
echo "==> Done. Restart your shell for changes to take effect."
