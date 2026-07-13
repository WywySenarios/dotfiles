#!/usr/bin/env bash
set -euo pipefail

npm install -g bun opencode-ai
(cd ~/dotfiles && git submodule update --init --recursive)