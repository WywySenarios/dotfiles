#!/usr/bin/env bash
# install.sh — install packages from packages.d/ and manage apt repositories
#
# Usage:
#   ./install.sh <section> [<section> ...]     # install packages
#   ./install.sh --repos [<repo> ...]          # setup apt repos (GPG keys + sources)
#
# Sections are paths relative to packages.d/, e.g.:
#   apt/core, apt/languages, npm/opencode, pipx/default
#
# The package manager is inferred from the first path component.
# Glob patterns work: apt/* installs all apt sections.
#
# Repos are subdirectories of packages.d/repos/.
# With no arguments, --repos sets up all repos.

set -euo pipefail

SELF="$(cd "$(dirname "$0")" && pwd)"
PKGS_DIR="$SELF"

# --- helpers ---

pkgs_from_file() {
	awk '!/^#/ && !/^$/ {print $1}' "$1" 2>/dev/null
}

infer_manager() {
	case "$(echo "$1" | cut -d/ -f1)" in
	apt) echo "apt" ;;
	npm) echo "npm" ;;
	pip) echo "pip" ;;
	pipx) echo "pipx" ;;
	go) echo "go" ;;
	*) echo "" ;;
	esac
}

# --- repos mode ---

if [ "${1:-}" = "--repos" ]; then
	shift
	repos_dir="$PKGS_DIR/repos"

	if [ $# -eq 0 ]; then
		mapfile -t repos < <(find "$repos_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
	else
		repos=("$@")
	fi

	for name in "${repos[@]}"; do
		repo_path="$repos_dir/$name"
		if [ ! -d "$repo_path" ]; then
			echo "Error: repo not found — $name" >&2
			exit 1
		fi

		echo "==> Setting up repo: $name"

		# GPG key
		if [ -f "$repo_path/key.url" ]; then
			key_url="$(tr -d '[:space:]' <"$repo_path/key.url")"
			keyring="/usr/share/keyrings/${name}-keyring.gpg"
			echo "    Fetching GPG key -> $keyring"
			curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
		fi

		# APT source
		if [ -f "$repo_path/source" ]; then
			src="$(cat "$repo_path/source")"
			src="${src//\$DISTRO/$(lsb_release -cs 2>/dev/null || echo bookworm)}"
			src="${src//\$ARCH/$(dpkg --print-architecture)}"
			dest="/etc/apt/sources.list.d/${name}.sources"
			echo "$src" | sudo tee "$dest" >/dev/null
			echo "    Installed source -> $dest"
		fi
	done

	echo "==> Running apt update..."
	sudo apt update
	echo "==> Done."
	exit 0
fi

# --- package install mode ---

if [ $# -eq 0 ]; then
	cat >&2 <<-'EOF'
		Usage: install.sh <section> [<section> ...]
		       install.sh --repos [<repo> ...]

		Sections are paths under packages.d/:
		  apt/core  apt/languages  npm/opencode  pipx/default  ...

		Globbing works:  install.sh apt/*
	EOF
	exit 1
fi

# Collect packages by manager (associative array as set for dedup)
declare -A apt_pkgs npm_pkgs pip_pkgs pipx_pkgs go_pkgs

for section in "$@"; do
	section_file="$PKGS_DIR/$section"
	[ -f "$section_file" ] || {
		echo "Error: not found — $section_file" >&2
		exit 1
	}

	manager="$(infer_manager "$section")"
	[ -n "$manager" ] || {
		echo "Error: unknown manager for '$section'" >&2
		exit 1
	}

	while IFS= read -r pkg; do
		[ -z "$pkg" ] && continue
		case "$manager" in
		apt) apt_pkgs["$pkg"]=1 ;;
		npm) npm_pkgs["$pkg"]=1 ;;
		pip) pip_pkgs["$pkg"]=1 ;;
		pipx) pipx_pkgs["$pkg"]=1 ;;
		go) go_pkgs["$pkg"]=1 ;;
		esac
	done < <(pkgs_from_file "$section_file")
done

# Install each group

if [ ${#apt_pkgs[@]} -gt 0 ]; then
	echo "==> Installing ${#apt_pkgs[@]} apt package(s)..."
	set -x
	sudo apt install -y "${!apt_pkgs[@]}"
	set +x
fi

if [ ${#npm_pkgs[@]} -gt 0 ]; then
	echo "==> Installing ${#npm_pkgs[@]} npm package(s) (global)..."
	set -x
	npm install -g "${!npm_pkgs[@]}"
	set +x
fi

if [ ${#pip_pkgs[@]} -gt 0 ]; then
	echo "==> Installing ${#pip_pkgs[@]} pip package(s)..."
	set -x
	pip install "${!pip_pkgs[@]}"
	set +x
fi

if [ ${#pipx_pkgs[@]} -gt 0 ]; then
	echo "==> Installing ${#pipx_pkgs[@]} pipx package(s)..."
	for pkg in "${!pipx_pkgs[@]}"; do
		set -x
		pipx install "$pkg"
		set +x
	done
fi

if [ ${#go_pkgs[@]} -gt 0 ]; then
	echo "==> Installing ${#go_pkgs[@]} Go module(s)..."
	for pkg in "${!go_pkgs[@]}"; do
		set -x
		go get "$pkg"
		set +x
	done
fi

echo "==> Done."
