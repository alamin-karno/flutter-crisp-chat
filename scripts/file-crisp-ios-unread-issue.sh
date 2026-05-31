#!/usr/bin/env bash
# Files a pre-written issue on crisp-im/crisp-sdk-ios using the GitHub CLI.
#
# Prerequisites:
#   brew install gh && gh auth login
#
# Usage:
#   ./scripts/file-crisp-ios-unread-issue.sh

set -euo pipefail

REPO="crisp-im/crisp-sdk-ios"
ISSUE_FILE="$(cd "$(dirname "$0")/.." && pwd)/docs/crisp-sdk-ios-unread-issue.md"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: GitHub CLI (gh) is not installed." >&2
  echo "Install: brew install gh && gh auth login" >&2
  echo "Or file manually: https://github.com/${REPO}/issues/new" >&2
  echo "Body template: ${ISSUE_FILE}" >&2
  exit 1
fi

TITLE="iOS SDK does not reset unread.visitor after visitor reads operator messages in ChatViewController"

# Extract body from markdown (skip title line and front separator)
BODY="$(awk 'NR>4' "$ISSUE_FILE")"

gh issue create \
  --repo "$REPO" \
  --title "$TITLE" \
  --body "$BODY"

echo "Issue filed on https://github.com/${REPO}/issues"
