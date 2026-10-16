#!/usr/bin/env bash
set -euo pipefail

# post_comment.sh: Safely posts a single review comment to GitHub or GitLab.
# Usage: post_comment.sh [--dry-run] <repo> <iid> <file> <line> <comment_file>

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  shift
fi

REPO="${1:-}"
IID="${2:-}"
FILE_PATH="${3:-}"
LINE="${4:-}"
BODY_FILE="${5:-}"

if [[ -z "$REPO" || -z "$IID" || -z "$FILE_PATH" || -z "$LINE" || -z "$BODY_FILE" ]]; then
  echo "Usage: $0 [--dry-run] <repo> <iid> <file> <line> <comment_file>" >&2
  exit 1
fi

BODY=$(cat "$BODY_FILE")

if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN (No comment will be posted) ==="
  echo "Repo: $REPO | PR: $IID"
  echo "Anchor: $FILE_PATH:L$LINE"
  echo "Body:"
  echo "$BODY"
  exit 0
fi

GIT_HOST="${GIT_HOST:-github.com}"

if [[ "$GIT_HOST" == *"gitlab"* ]]; then
  glab mr note create "$IID" -R "$REPO" -m "$BODY"
else
  # Use gh pr comment
  gh pr comment "$IID" -R "$REPO" --body "$BODY"
fi
