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

# --- create user + subuids/subgids for podman ---
useradd -m -u 11111 -s /bin/bash "${USER}"
usermod --add-subuids 100000-165535 "${USER}"
usermod --add-subgids 100000-165535 "${USER}"

# --- manage secrets ---
groupadd get-secrets
usermod -a -G get-secrets podadmin
chown root:get-secrets "${SECRETS_FILE}"
chmod 640 "${SECRETS_FILE}"
