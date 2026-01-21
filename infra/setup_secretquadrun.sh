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


echo "Debug: FQDN is set to [$FQDN]"

# --- create secret + move quadlet service file + make pod yaml discoverable by quadlet service ---
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
