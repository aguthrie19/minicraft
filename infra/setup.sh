#!/usr/bin/env bash
set -euo pipefail

# -----------------
# --- VARIABLES ---
# -----------------
REPO=$(dirname $(dirname $(realpath "${BASH_SOURCE[0]}")))
IP_EXT=$(wget -qO- https://www.icanhazip.com)
FQDN=$(getent -s dns hosts $IP_EXT | awk '{print $2}')
SECRETS_FILE="${REPO}/infra/secrets.yml"
USER="podadmin"

source "$REPO"/ops/get_helpers.sh
get_helpers

# --------------
# --- ACCESS ---
# --------------

chown -R root:root "$REPO"
chmod -R 770 "$REPO"

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
networkctl reload
networkctl reconfigure dumpodintf

# --- apply root firewall with nftables ---
mkdir -p /etc/nftables.d/
cp "${REPO}/infra/pod.nft" /etc/nftables.d/pod.nft
nftcfg_add2chain /etc/nftables.conf /etc/nftables.d/pod.nft pod_input "inet filter input"
systemctl enable --now nftables

# --- create user + subuids/subgids for podman ---
useradd -m -u 11111 -s /bin/bash "${USER}"
usermod --add-subuids 100000-165535 "${USER}"
usermod --add-subgids 100000-165535 "${USER}"
chown -R root:"$USER" "$REPO"

# --- manage secrets ---
groupadd get-secrets
usermod -a -G get-secrets podadmin
chown root:get-secrets "${SECRETS_FILE}"
chmod 640 "${SECRETS_FILE}"

# --- persistent systemd user session & podman api ---
loginctl enable-linger "${USER}"
sudo -iu "${USER}" env XDG_RUNTIME_DIR=/run/user/11111 bash -lc 'systemctl --user enable --now podman.socket'

# --- build images ---
sudo -iu "${USER}" bash -lc "
  podman build -t auth:latest --build-arg DKFDIR='tnrfls/auth' -f '${REPO}/tnrfls/auth/Dockerfile' '${REPO}' && \
  podman build -t stats:latest --build-arg DKFDIR='tnrfls/stats' -f '${REPO}/tnrfls/stats/Dockerfile' '${REPO}' && \
  podman build -t app:latest --build-arg DKFDIR='tnrfls/app' -f '${REPO}/tnrfls/app/Dockerfile' '${REPO}'
"
# tag, inject arg, file to build, working directory context

# --- create secret + move quadlet service file + make pod yaml discoverable by quadlet service ---
echo "Debug: FQDN is set to [$FQDN]"
sudo -iu "${USER}" bash -lc "
  podman kube play '${SECRETS_FILE}' && \
  mkdir -p ~/.config/containers/systemd && \
  cp '${REPO}/infra/minicraftpod.kube' ~/.config/containers/systemd/minicraftpod.kube && \
  FQDN='${FQDN}' < '${REPO}/infra/pod.yml' envsubst > ~/.config/containers/systemd/pod.yml
"
# cp '${REPO}/infra/pod.yml' ~/.config/containers/systemd/pod.yml

# --- enable systemd therefore quadlet service ---
sudo -iu "${USER}" env XDG_RUNTIME_DIR=/run/user/11111 bash -lc "
  systemctl --user daemon-reload && \
  systemctl --user start --now minicraftpod.service
"
