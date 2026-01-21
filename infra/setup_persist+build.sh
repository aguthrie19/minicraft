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

# --- persistent systemd user session & podman api ---
loginctl enable-linger "${USER}"
sudo -iu "${USER}" env XDG_RUNTIME_DIR=/run/user/11111 bash -lc 'systemctl --user enable --now podman.socket'

# --- build images ---
sudo -iu "${USER}" bash -lc "
podman build -t auth:latest '${REPO}/tnrfls/auth' && \
podman build -t stats:latest '${REPO}/tnrfls/stats' && \
podman build -t app:latest '${REPO}/tnrfls/app'
"
