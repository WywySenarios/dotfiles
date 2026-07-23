#!/usr/bin/env bash
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

sudo apt-get install -y \
	vim \
	neovim
