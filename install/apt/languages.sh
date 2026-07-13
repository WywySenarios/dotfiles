#!/usr/bin/env bash
set -euo pipefail

apt-get install -y \
	shfmt \
	golang-go \
	rustfmt \
	cargo \
	clang-format \
	nodejs \
	npm
