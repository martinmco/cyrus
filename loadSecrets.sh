#!/usr/bin/env bash
# Cache the maintained Cyrus installation's existing Bitwarden secrets in Keychain.
#
# Same contract as mLinear's loadSecrets.sh: Martin maintains Bitwarden only.
# This script unlocks, syncs, reads each item's Password field, and caches it in
# Keychain so non-interactive shells (which cannot unlock Bitwarden) can read it.
#
# Run once in an INTERACTIVE terminal, and again whenever a secret rotates:
#     ./loadSecrets.sh
set -euo pipefail

LOG_PREFIX="[loadSecrets]"

# Bitwarden item name  ->  Keychain service name
SECRETS=(
  "cyrus-linear-client-id:cyrus_linear_client_id"
  "cyrus-linear-client-secret:cyrus_linear_client_secret"
  "cyrus-linear-webhook-secret:cyrus_linear_webhook_secret"
  "cyrus-github-token:cyrus_github_token"
)

command -v bw >/dev/null 2>&1 || { echo "$LOG_PREFIX bw CLI not found" >&2; exit 2; }
[ -x /opt/homebrew/bin/jq ] || { echo "$LOG_PREFIX jq missing at /opt/homebrew/bin/jq" >&2; exit 2; }
[ -t 0 ] || { echo "$LOG_PREFIX must run in an interactive terminal (Bitwarden needs to unlock)" >&2; exit 2; }

status="$(bw status | sed -n 's/.*"status":"\([a-z]*\)".*/\1/p')"
if [ "$status" != "unlocked" ]; then
  echo "$LOG_PREFIX unlocking Bitwarden..."
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
fi

# Sync-first rule: desktop-first vault changes are otherwise invisible to the CLI.
echo "$LOG_PREFIX syncing vault..."
bw sync >/dev/null

missing=0
for pair in "${SECRETS[@]}"; do
  item="${pair%%:*}"
  service="${pair##*:}"

  matches="$(bw list items --search "$item" | /opt/homebrew/bin/jq -c --arg name "$item" '[.[] | select(.name == $name)]')"
  match_count="$(printf '%s' "$matches" | /opt/homebrew/bin/jq 'length')"
  if [ "$match_count" != 1 ]; then
    echo "$LOG_PREFIX expected one exact Bitwarden item '$item'; found $match_count" >&2
    echo "$LOG_PREFIX   create a Login item named exactly '$item' with the secret in the Password field" >&2
    missing=$((missing + 1))
    continue
  fi
  value="$(printf '%s' "$matches" | /opt/homebrew/bin/jq -r '.[0].login.password // empty')"
  if [ -z "$value" ]; then
    echo "$LOG_PREFIX empty Password field in '$item'" >&2
    missing=$((missing + 1))
    continue
  fi

  security add-generic-password -U -a "$USER" -s "$service" -w "$value"
  chars="$(security find-generic-password -a "$USER" -s "$service" -w | wc -c | tr -d ' ')"
  echo "$LOG_PREFIX cached $item -> $service ($chars chars)"
done
unset value matches

if [ "$missing" -gt 0 ]; then
  echo "$LOG_PREFIX $missing secret(s) missing; add them to Bitwarden and re-run" >&2
  exit 1
fi
echo "$LOG_PREFIX all secrets cached"
