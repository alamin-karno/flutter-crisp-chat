#!/usr/bin/env bash
# Verifies whether Crisp REST unread.visitor is cleared after reading chat in the
# native mobile SDK, and whether manual PATCH /read works as a control test.
#
# Required environment variables:
#   CRISP_WEBSITE_ID   - Crisp website identifier
#   CRISP_IDENTIFIER   - Marketplace plugin REST API identifier
#   CRISP_KEY          - Marketplace plugin REST API key
#   CRISP_SESSION_ID   - Active conversation session ID (from getSessionIdentifier)
#
# Usage:
#   export CRISP_WEBSITE_ID=... CRISP_IDENTIFIER=... CRISP_KEY=... CRISP_SESSION_ID=...
#   ./scripts/verify_unread_read_receipts.sh get          # read current unread.visitor
#   ./scripts/verify_unread_read_receipts.sh mark-read    # PATCH /read (control test)
#   ./scripts/verify_unread_read_receipts.sh full         # get → mark-read → get

set -euo pipefail

API_BASE="https://api.crisp.chat/v1"

require_env() {
  local missing=0
  for var in CRISP_WEBSITE_ID CRISP_IDENTIFIER CRISP_KEY CRISP_SESSION_ID; do
    if [[ -z "${!var:-}" ]]; then
      echo "ERROR: $var is not set" >&2
      missing=1
    fi
  done
  if [[ "$missing" -eq 1 ]]; then
    echo >&2
    echo "Set credentials from your Crisp Marketplace plugin token." >&2
    echo "Session ID comes from FlutterCrispChat.getSessionIdentifier()." >&2
    exit 1
  fi
}

auth_header() {
  printf 'Basic %s' "$(printf '%s:%s' "$CRISP_IDENTIFIER" "$CRISP_KEY" | base64)"
}

get_unread_visitor() {
  local response
  response="$(curl -sS \
    -H "Authorization: $(auth_header)" \
    -H "X-Crisp-Tier: plugin" \
    "${API_BASE}/website/${CRISP_WEBSITE_ID}/conversation/${CRISP_SESSION_ID}")"

  echo "$response" | python3 -c "
import json, sys
data = json.load(sys.stdin)
unread = data.get('data', {}).get('unread', {})
print(json.dumps(unread, indent=2))
visitor = unread.get('visitor')
if visitor is None:
    sys.exit(2)
print(f'unread.visitor={visitor}', file=sys.stderr)
"
}

mark_read() {
  curl -sS -X PATCH \
    -H "Authorization: $(auth_header)" \
    -H "X-Crisp-Tier: plugin" \
    -H "Content-Type: application/json" \
    -d '{"from":"operator","origin":"chat"}' \
    "${API_BASE}/website/${CRISP_WEBSITE_ID}/conversation/${CRISP_SESSION_ID}/read" \
    -w "\nHTTP_STATUS:%{http_code}\n"
}

cmd="${1:-get}"
require_env

case "$cmd" in
  get)
    echo "GET conversation unread counters:"
    get_unread_visitor
    ;;
  mark-read)
    echo "PATCH mark messages as read:"
    mark_read
    echo
    echo "Waiting 3s for server to update..."
    sleep 3
    echo "GET conversation unread counters after mark-read:"
    get_unread_visitor
    ;;
  full)
    echo "=== Step 1: GET unread before mark-read ==="
    get_unread_visitor
    echo
    echo "=== Step 2: PATCH mark-read (control test) ==="
    mark_read
    echo
    echo "Waiting 3s..."
    sleep 3
    echo "=== Step 3: GET unread after mark-read ==="
    get_unread_visitor
    echo
    echo "If step 3 shows unread.visitor=0, REST mark-read works."
    echo "If unread stayed >0 after reading in iOS chat but step 3 is 0, the iOS SDK read-receipt path is broken."
    ;;
  *)
    echo "Usage: $0 {get|mark-read|full}" >&2
    exit 1
    ;;
esac
