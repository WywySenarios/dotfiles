#!/usr/bin/env bash
# install/fonts/nerd-font.sh — FiraCode Nerd Font (fallback for icon glyphs)
set -euo pipefail

FONT_DIR="${HOME}/.local/share/fonts"
ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
ZIP_TMP="/tmp/FiraCode.zip"

echo "==> Downloading FiraCode Nerd Font..."
curl -fsSL "$ZIP_URL" -o "$ZIP_TMP"

echo "==> Extracting to ${FONT_DIR}..."
mkdir -p "$FONT_DIR"
unzip -q -o "$ZIP_TMP" -d "$FONT_DIR"
rm -f "$ZIP_TMP"

echo "==> Updating font cache..."
fc-cache -fv

echo "==> FiraCode Nerd Font installed to ${FONT_DIR}"
