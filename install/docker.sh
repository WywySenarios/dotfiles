#!/usr/bin/env bash
# Install Docker Engine on Debian via the official apt repository.
# This script must be run with sudo (or as root with sudo available).
set -euo pipefail

if ! command -v sudo &>/dev/null; then
	echo "This script assumes that sudo is available." >&2
	exit 1
fi

# ---------------------------------------------------------------------------
# 1. Uninstall any conflicting packages
# ---------------------------------------------------------------------------
echo "==> Removing conflicting packages..."
sudo apt-get remove -y \
	docker.io \
	docker-compose \
	docker-doc \
	podman-docker \
	containerd \
	runc \
	2>/dev/null || true

# ---------------------------------------------------------------------------
# 2. Install dependencies for the apt repository method
# ---------------------------------------------------------------------------
echo "==> Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl

# ---------------------------------------------------------------------------
# 3. Add Docker's official GPG key
# ---------------------------------------------------------------------------
echo "==> Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# ---------------------------------------------------------------------------
# 4. Add the Docker apt repository
# ---------------------------------------------------------------------------
echo "==> Adding Docker apt repository..."
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
ARCH=$(dpkg --print-architecture)

sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt-get update

# ---------------------------------------------------------------------------
# 5. Install Docker Engine
# ---------------------------------------------------------------------------
echo "==> Installing Docker Engine..."
sudo apt-get install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

# ---------------------------------------------------------------------------
# 6. Enable and start the Docker daemon
# ---------------------------------------------------------------------------
echo "==> Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# ---------------------------------------------------------------------------
# 7. Add user to the docker group
# ---------------------------------------------------------------------------
echo "==> Creating docker group and adding user..."
sudo groupadd -f docker
if [ -n "${SUDO_USER:-}" ]; then
	sudo usermod -aG docker "$SUDO_USER"
	echo "  User '$SUDO_USER' added to the docker group."
	echo "  Log out and back in for the change to take effect."
else
	echo "  Could not determine the original user (SUDO_USER is unset)." >&2
	echo "  You may need to run: sudo usermod -aG docker \$USER" >&2
fi

# ---------------------------------------------------------------------------
# 8. Verify installation
# ---------------------------------------------------------------------------
echo "==> Verifying installation..."
sudo docker run --rm hello-world 2>/dev/null

echo ""
echo "  Docker Engine $(docker --version 2>/dev/null) installed"
echo "  Docker Compose $(docker compose version 2>/dev/null) installed"
