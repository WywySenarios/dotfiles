#!/usr/bin/env bash
set -euo pipefail

# Guard: sudo is required
if ! command -v sudo &>/dev/null; then
	echo "sudo is required but not found. Install sudo first." >&2
	exit 1
fi

sudo apt-get update

# Install containerd
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install kubeadm, kubelet, kubectl (v1.36)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
sudo apt-get update
sudo apt-get install -y --allow-change-held-packages kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable IP forwarding (kubeadm preflight check)
sudo sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-kubernetes.conf

# Initialize control plane
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl
mkdir -p "$HOME/.kube"
sudo cp /etc/kubernetes/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
kubectl cluster-info
kubectl get nodes # should show one Ready node (NotReady until CNI is installed)

# Apply default Calico CNI
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

# Label self as control-plane node
kubectl label node "$(hostname)" wywy.io/role=control-plane

# --- Script contract: join token for worker VMs ---
echo ""
echo "=============================================="
echo "  Control plane is ready."
echo "  Run this on each worker VM to join the cluster:"
echo "=============================================="
sudo kubeadm token create --print-join-command
echo "=============================================="
echo ""
echo "Note: The control plane node is tainted."
echo "Worker VMs will receive all workload pods."
