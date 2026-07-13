#!/usr/bin/env bash
# packages/manual/default.sh — tools without a package manager
# These must be installed by hand. This script prints instructions.
set -euo pipefail

cat <<'EOF'
The following tools have no package manager and must be installed manually:

# Go binary tarball (when apt version is too old or you need a specific version)
#   wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -O /tmp/go.tar.gz
#   sudo tar -C /usr/local -xzf /tmp/go.tar.gz

# Node Version Manager (nvm)
#   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
#   Then: nvm install --lts

# air — R code formatter
#   curl -LO https://github.com/posit-dev/air/releases/latest/download/air-x86_64-unknown-linux-gnu
#   chmod +x air-x86_64-unknown-linux-gnu
#   sudo mv air-x86_64-unknown-linux-gnu /usr/local/bin/air

# opencode-rbash plugin dependencies
#   cd plugins/opencode-rbash && npm install
EOF
