#!/usr/bin/env bash
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "sudo is required." >&2
	exit 1
fi

sudo apt-get install -y python3 python3-pip python3-venv

if ! command -v uv &>/dev/null; then
	echo "==> Installing uv..."
	curl -LsSf https://astral.sh/uv/install.sh | sh
else
	echo "==> uv already installed, skipping"
fi

uv tool install ruff
