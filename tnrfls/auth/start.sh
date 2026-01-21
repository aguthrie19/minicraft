#!/usr/bin/env sh

# if this script ends, then all sub-processes end
trap 'kill $(jobs -p)' TERM EXIT

# VARIABLES (local to this script, not environment)
OAUTH2_PROXY_REDIRECT_URL="https://${FQDN}/oauth2/callback"
OAUTH2_PROXY_COOKIE_SECRET=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_')
OAUTH2_PROXY_CLIENT_ID="$(cat /secrets/manual_client_id)"
#OAUTH2_PROXY_CLIENT_SECRET="$(cat /secrets/manual_client_secret)"

# caddy in background
caddy run --config /auth/Caddyfile &

# oauth2-proxy in background
oauth2-proxy \
  --config=/auth/oauth2-proxy.cfg \
  --redirect-url="$OAUTH2_PROXY_REDIRECT_URL" \
  --cookie-secret="$OAUTH2_PROXY_COOKIE_SECRET" \
  --client-id="$OAUTH2_PROXY_CLIENT_ID" \
  --client-secret-file=/secrets/manual_client_secret \
&

# if either sub-process fails, then this script ends
wait -n
