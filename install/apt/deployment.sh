#!/usr/bin/env bash
set -euo pipefail

apt-get install -y \
	containerd \
	docker.io \
	kubelet \
	kubeadm \
	kubectl \
	proxmox-ve \
	postfix \
	open-iscsi \
	xorriso \
	syslinux-utils
