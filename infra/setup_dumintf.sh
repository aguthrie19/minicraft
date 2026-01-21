#!/usr/bin/env bash

# -----------------
# --- VARIABLES ---
# -----------------
REPO=$(dirname $(dirname $(realpath "${BASH_SOURCE[0]}")))
IP_EXT=$(wget -qO- https://www.icanhazip.com)
FQDN=$(getent -s dns hosts $IP_EXT | awk '{print $2}')
SECRETS_FILE="${REPO}/infra/secrets.yml"
USER="podadmin"

source "$REPO"/ops/get_helpers.sh

export FQDN

# --------------
# --- ACCESS ---
# --------------

chown -R root:"$USER" "$REPO"
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
