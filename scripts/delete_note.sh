#!/usr/bin/env bash
set -euo pipefail

# delete_note.sh: Deletes an erroneous comment note by ID.
# Usage: delete_note.sh <repo> <iid> <note_id>

REPO="${1:-}"
IID="${2:-}"
NOTE_ID="${3:-}"

if [[ -z "$REPO" || -z "$NOTE_ID" ]]; then
  echo "Usage: $0 <repo> <iid> <note_id>" >&2
  exit 1
fi

GIT_HOST="${GIT_HOST:-github.com}"

if [[ "$GIT_HOST" == *"gitlab"* ]]; then
  echo "Deleting note on GitLab..."
else
  gh api -X DELETE "repos/${REPO}/pulls/comments/${NOTE_ID}"
fi
