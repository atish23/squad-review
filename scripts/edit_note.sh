#!/usr/bin/env bash
set -euo pipefail

# edit_note.sh: Updates an existing comment note.
# Usage: edit_note.sh <repo> <iid> <note_id> <body_file>

REPO="${1:-}"
IID="${2:-}"
NOTE_ID="${3:-}"
BODY_FILE="${4:-}"

if [[ -z "$REPO" || -z "$NOTE_ID" || -z "$BODY_FILE" ]]; then
  echo "Usage: $0 <repo> <iid> <note_id> <body_file>" >&2
  exit 1
fi

BODY=$(cat "$BODY_FILE")
GIT_HOST="${GIT_HOST:-github.com}"

if [[ "$GIT_HOST" == *"gitlab"* ]]; then
  echo "Editing notes on GitLab via API..."
else
  gh api -X PATCH "repos/${REPO}/pulls/comments/${NOTE_ID}" -f body="$BODY"
fi
