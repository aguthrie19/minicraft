#!/usr/bin/env bash

# -----------------
# --- VARIABLES ---
# -----------------
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_IP=$(curl -s https://ifconfig.me)
FQDN=$(getent hosts "$PUBLIC_IP" | awk '{print $2}')
export FQDN
SECRETS_FILE="${REPO}/secrets.env"
USER="podadmin"

# ---------------
# --- INSTALL ---
# ---------------
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y nftables passt podman

# --- apply root dummy interface ---
# use files to tell root daemon to create network interface & assign it a static IP
# /etc/systemd/network/dumpodintf.netdev
# /etc/systemd/network/dumpodintf.network
cp "${REPO}/infra/25-dumpodintf.netdev" /etc/systemd/network/25-dumpodintf.netdev
cp "${REPO}/infra/25-dumpodintf.network" /etc/systemd/network/25-dumpodintf.network
chmod 644 /etc/systemd/network/25-dumpodintf.*
# enable the root daemon 
systemctl enable --now systemd-networkd

# --- apply root firewall with nftables ---
cp "${REPO}/infra/nftables.conf" /etc/nftables.conf
systemctl enable --now nftables

# --- create user + subuids/subgids for podman ---
useradd -m -u 11111 -s /bin/bash "${USER}"
usermod --add-subuids 100000-165535 "${USER}"
usermod --add-subgids 100000-165535 "${USER}"

# --- manage secrets ---
groupadd get-secrets
usermod -a -G get-secrets podadmin
chown root:get-secrets "${SECRETS_FILE}"
chmod 640 "${SECRETS_FILE}"

# --- persistent systemd user session & podman api ---
loginctl enable-linger "${USER}"
sudo -iu "${USER}" bash -lc 'systemctl --user enable --now podman.socket'

# --- build images ---
sudo -iu "${USER}" bash -lc "
  podman build -t auth:latest '${REPO}/tnrs/auth'
  podman build -t stats:latest '${REPO}/tnrs/stats'
  podman build -t app:latest '${REPO}/tnrs/app'
"

# --- create secret + move quadlet service file + make pod yaml discoverable by quadlet service ---
sudo -iu "${USER}" bash -lc "
  podman secret create authsecrets '${SECRETS_FILE}'
  mkdir -p ~/.config/containers/systemd
  cp '${REPO}/infra/minicraftpod.kube' ~/.config/containers/systemd/minicraftpod.kube
  cp '${REPO}/infra/pod.yml' ~/.config/containers/systemd/pod.yml
"

# --- enable systemd therefore quadlet service ---
sudo -iu "${USER}" bash -lc "
  systemctl --user daemon-reload
  systemctl --user start --now minicraftpod.service
"
