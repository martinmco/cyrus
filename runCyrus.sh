#!/bin/bash
# Foreground ownership of the worker and tunnel; launchd supervises this script.
set -euo pipefail
umask 077
cd "$(dirname "$0")"
CYRUS_REPO="$(pwd -P)"
CYRUS_NODE="${CYRUS_NODE:-/opt/homebrew/Cellar/node/26.8.2/bin/node}"
CYRUS_CLOUDFLARED="${CYRUS_CLOUDFLARED:-$CYRUS_REPO/.runtime/bin/cloudflared}"
CYRUS_RUNTIME_HOME="${CYRUS_RUNTIME_HOME:-$HOME/.cyrus}"
CYRUS_LOCAL_URL="http://localhost:3456/status"
export PATH="/Users/martin/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export CYRUS_HOME="$CYRUS_RUNTIME_HOME"
export LINEAR_DIRECT_WEBHOOKS=true
export CYRUS_BASE_URL=https://cyrus.martinm.co
export CYRUS_SERVER_PORT=3456
export CYRUS_HOST_EXTERNAL=false
export CYRUS_ENABLE_WARM_SESSIONS=0
export CYRUS_DISABLE_REMOTE_SESSION_STORE=1
export CYRUS_SENTRY_DISABLED=true

for file in "$CYRUS_NODE" "$CYRUS_CLOUDFLARED" "$CYRUS_REPO/apps/cli/dist/src/app.js" "$CYRUS_HOME/config.json" "$HOME/.cloudflared/d3edf5f6-e265-4eb9-a775-7a2ab36050c3.json"; do
  [ -f "$file" ] || { echo "[Cyrus] Missing dependency: $file" >&2; exit 2; }
done
keychain() {
  /usr/bin/security find-generic-password -a "$(/usr/bin/id -un)" -s "$1" -w 2>/dev/null || {
    echo "[Cyrus] Cannot read Keychain cache '$1'; use ./loadSecrets.sh in an interactive terminal." >&2
    return 2
  }
}
LINEAR_CLIENT_ID="$(keychain cyrus_linear_client_id)"
LINEAR_CLIENT_SECRET="$(keychain cyrus_linear_client_secret)"
LINEAR_WEBHOOK_SECRET="$(keychain cyrus_linear_webhook_secret)"
GH_TOKEN="$(keychain cyrus_github_token)"
export LINEAR_CLIENT_ID LINEAR_CLIENT_SECRET LINEAR_WEBHOOK_SECRET GH_TOKEN
export GITHUB_TOKEN="$GH_TOKEN"

case "${1:-start}" in
  check)
    "$CYRUS_NODE" "$CYRUS_REPO/apps/cli/dist/src/app.js" --version
    "$CYRUS_CLOUDFLARED" --version
    "$CYRUS_NODE" "$CYRUS_REPO/scripts/check-mac-connection.mjs"
    exit 0
    ;;
  start) ;;
  *) echo 'usage: ./runCyrus.sh [start|check]' >&2; exit 2 ;;
esac

if /usr/bin/curl --silent --fail --max-time 2 "$CYRUS_LOCAL_URL" >/dev/null; then
  echo '[Cyrus] Port 3456 already serves a worker; refusing a duplicate.' >&2
  exit 2
fi
worker_pid=""
tunnel_pid=""
cleanup() {
  trap - EXIT INT TERM
  for child in "$tunnel_pid" "$worker_pid"; do
    if [ -n "$child" ]; then kill "$child" 2>/dev/null || true; fi
  done
  for child in "$tunnel_pid" "$worker_pid"; do
    if [ -n "$child" ]; then wait "$child" 2>/dev/null || true; fi
  done
}
trap cleanup EXIT
trap 'exit 0' INT TERM
echo "[Cyrus] Starting maintained fork ($CYRUS_REPO)"
"$CYRUS_NODE" "$CYRUS_REPO/apps/cli/dist/src/app.js" start &
worker_pid=$!
deadline=$((SECONDS + 60))
until /usr/bin/curl --silent --fail --max-time 2 "$CYRUS_LOCAL_URL" >/dev/null; do
  kill -0 "$worker_pid" 2>/dev/null || { echo '[Cyrus] Worker exited before readiness.' >&2; exit 1; }
  [ "$SECONDS" -lt "$deadline" ] || { echo '[Cyrus] Worker readiness timed out.' >&2; exit 1; }
  sleep 1
done
"$CYRUS_CLOUDFLARED" --no-autoupdate --config "$CYRUS_REPO/deploy/mac/tunnel.yml" tunnel run &
tunnel_pid=$!
echo '[Cyrus] Worker ready; tunnel starting.'
while kill -0 "$worker_pid" 2>/dev/null && kill -0 "$tunnel_pid" 2>/dev/null; do
  sleep 1
done
echo '[Cyrus] Worker or tunnel exited; stopping its sibling for a clean restart.' >&2
exit 1
