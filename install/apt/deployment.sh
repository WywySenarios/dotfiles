#!/usr/bin/env bash
set -euo pipefail

apt-get install -y \
	containerd \
	docker.io \
	proxmox-ve \
	postfix \
	open-iscsi \
	xorriso \
	syslinux-utils
