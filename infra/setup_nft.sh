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

# --- apply root firewall with nftables ---
mkdir -p /etc/nftables.d/
cp "${REPO}/infra/pod.nft" /etc/nftables.d/pod.nft
nftcfg_add2chain /etc/nftables.conf /etc/nftables.d/pod.nft pod_input "inet filter input"
systemctl enable --now nftables
