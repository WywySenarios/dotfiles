#!/usr/bin/env bash
# install/ide/vscode.sh — VS Code APT repository + config deployment
set -euo pipefail
REPO="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
CONFIG_SRC="$REPO/constants/.vscode"

# ── Helper ──────────────────────────────────────────────────────────────────
ensure_parent_dir() {
	local d="$1"
	local parent
	parent="$(dirname "$d")"
	if [ ! -d "$parent" ]; then
		mkdir -p "$parent"
	fi
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

# ── Install VS Code binary ──────────────────────────────────────────────────
install_vscode() {
	if command -v code &>/dev/null; then
		echo "==> VS Code already installed. Skipping package install."
		return
	fi

	if ! command -v sudo &>/dev/null; then
		echo "This script assumes that sudo is available." >&2
		exit 1
	fi

	local arch keyring
	arch="$(dpkg --print-architecture)"
	keyring="/usr/share/keyrings/vscode-keyring.gpg"

	curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | sudo gpg --dearmor --yes -o "$keyring"

	echo "deb [arch=$arch signed-by=$keyring] https://packages.microsoft.com/repos/code stable main" |
		sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

	sudo apt-get update
	sudo apt-get install -y code
}

# ── Deploy config symlinks ──────────────────────────────────────────────────
deploy_config() {
	echo ""
	echo "==> Deploying VS Code configuration from $CONFIG_SRC"

	# --- settings.json → ~/.config/Code/User/settings.json ---
	deploy_symlink "$CONFIG_SRC/settings.json" "$HOME/.config/Code/User/settings.json"

	# --- chatLanguageModels.json → ~/.config/Code/User/chatLanguageModels.json ---
	deploy_symlink "$CONFIG_SRC/chatLanguageModels.json" "$HOME/.config/Code/User/chatLanguageModels.json"
}

# ── Install extensions ──────────────────────────────────────────────────────
install_extensions() {
	local ext_file="$CONFIG_SRC/extensions.txt"
	if [ ! -f "$ext_file" ]; then
		echo "==> SKIP  $ext_file  (not found)"
		return
	fi

	if ! command -v code &>/dev/null; then
		echo "==> SKIP  code CLI not available — install VS Code first, then re-run to install extensions"
		return
	fi

	echo "==> Installing VS Code extensions from $ext_file"

	# Snapshot already-installed extensions
	local -A installed
	local ext_id
	while IFS= read -r ext_id; do
		installed["$ext_id"]=1
	done < <(code --list-extensions 2>/dev/null || true)

	local missing=0
	while IFS= read -r ext_id; do
		# skip blank / comment lines
		case "$ext_id" in
		'' | '#'*) continue ;;
		esac
		if [[ -v installed["$ext_id"] ]]; then
			echo "    SKIP  $ext_id  (already installed)"
		else
			echo "    INSTALL  $ext_id ..."
			code --install-extension "$ext_id" --force || true
			((missing++)) || true
		fi
	done <"$ext_file"

	if [ "$missing" -eq 0 ]; then
		echo "    All extensions already installed."
	fi
}

# ── Main ────────────────────────────────────────────────────────────────────
case "${1:-install}" in
install)
	install_vscode
	deploy_config
	install_extensions
	;;
config)
	deploy_config
	install_extensions
	;;
*)
	echo "Usage: $0 [install|config]" >&2
	exit 1
	;;
esac

echo ""
echo "==> Done. Restart VS Code for changes to take effect."
