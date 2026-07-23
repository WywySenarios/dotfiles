#!/usr/bin/env bash
# Install bats (Bash Automated Testing System) and helper libraries.
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

sudo apt-get update
sudo apt-get install -y bats bats-assert bats-file bats-support

echo ""
echo "  bats $(bats --version 2>/dev/null) installed"
