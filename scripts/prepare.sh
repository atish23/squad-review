#!/usr/bin/env bash
set -euo pipefail

# squad-review prepare script
# Usage: prepare.sh <repo> <iid>

TARGET_REPO="${1:-}"
PR_IID="${2:-}"

if [[ -z "$TARGET_REPO" || -z "$PR_IID" ]]; then
  echo "Usage: $0 <repo> <iid>" >&2
  exit 1
fi

GIT_HOST="${GIT_HOST:-github.com}"
DEFAULT_ORG="${DEFAULT_ORG:-yourorg}"
CLONE_BASE_DIR="${CLONE_BASE_DIR:-$HOME/projects}"

# Ensure org prefix
if [[ "$TARGET_REPO" != *"/"* ]]; then
  FULL_REPO="${DEFAULT_ORG}/${TARGET_REPO}"
  REPO_NAME="$TARGET_REPO"
else
  FULL_REPO="$TARGET_REPO"
  REPO_NAME="${TARGET_REPO##*/}"
fi

TIMESTAMP=$(date +%s)
WORKDIR="/tmp/squad-review-${REPO_NAME}-${PR_IID}-${TIMESTAMP}"
mkdir -p "$WORKDIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Initializing working directory: $WORKDIR" >&2

# 1. Fetch metadata, diffs, threads, pipeline
bash "$SCRIPT_DIR/fetch_mr.sh" "$FULL_REPO" "$PR_IID" "$WORKDIR"

# 2. Annotate diff lines (old|new| line markers)
if [[ -f "$WORKDIR/diffs.json" ]]; then
  python3 "$SCRIPT_DIR/annotate_diff.py" "$WORKDIR/diffs.json" > "$WORKDIR/annotated.txt"
fi

# 3. Match historical precedents
if [[ -f "$WORKDIR/diffs.json" ]]; then
  python3 "$SCRIPT_DIR/precedents.py" "$WORKDIR/diffs.json" > "$WORKDIR/precedents.txt"
fi

# 4. Fetch PR head into local clone if available
LOCAL_CLONE="${CLONE_BASE_DIR}/${REPO_NAME}"
if [[ -d "$LOCAL_CLONE/.git" ]]; then
  (cd "$LOCAL_CLONE" && git fetch origin >/dev/null 2>&1 || true)
fi

# Output the workdir on the very last line
echo "WORKDIR=$WORKDIR"
