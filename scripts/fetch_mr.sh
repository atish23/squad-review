#!/usr/bin/env bash
set -euo pipefail

# fetch_mr.sh: pulls PR metadata, commits, diffs, threads, pipeline status
# Usage: fetch_mr.sh <repo> <iid> <workdir>

REPO="$1"
IID="$2"
WORKDIR="$3"

GIT_HOST="${GIT_HOST:-github.com}"

mkdir -p "$WORKDIR"

if [[ "$GIT_HOST" == *"gitlab"* ]]; then
  # GitLab support via glab
  glab mr view "$IID" -R "$REPO" --output json > "$WORKDIR/mr.json" 2>/dev/null || echo "{}" > "$WORKDIR/mr.json"
  glab mr diff "$IID" -R "$REPO" > "$WORKDIR/diff.patch" 2>/dev/null || touch "$WORKDIR/diff.patch"
  glab mr view "$IID" -R "$REPO" --comments > "$WORKDIR/existing_threads.json" 2>/dev/null || echo "[]" > "$WORKDIR/existing_threads.json"
  glab ci status -R "$REPO" --output json > "$WORKDIR/pipeline.json" 2>/dev/null || echo "{}" > "$WORKDIR/pipeline.json"
else
  # Default to GitHub via gh
  if command -v gh >/dev/null 2>&1; then
    gh pr view "$IID" -R "$REPO" --json title,body,author,headRefName,baseRefName,headRefOid,baseRefOid > "$WORKDIR/mr.json" 2>/dev/null || echo "{}" > "$WORKDIR/mr.json"
    gh pr diff "$IID" -R "$REPO" > "$WORKDIR/diff.patch" 2>/dev/null || touch "$WORKDIR/diff.patch"
    gh pr view "$IID" -R "$REPO" --json comments,reviews > "$WORKDIR/existing_threads.json" 2>/dev/null || echo "[]" > "$WORKDIR/existing_threads.json"
    gh pr checks "$IID" -R "$REPO" --json name,state,conclusion > "$WORKDIR/pipeline.json" 2>/dev/null || echo "{}" > "$WORKDIR/pipeline.json"
  else
    # Minimal fallback mock for local testing
    echo "{\"title\": \"PR $IID\", \"body\": \"Manual test context\"}" > "$WORKDIR/mr.json"
    touch "$WORKDIR/diff.patch"
    echo "[]" > "$WORKDIR/existing_threads.json"
    echo "{}" > "$WORKDIR/pipeline.json"
  fi
fi

# Convert diff.patch to diffs.json structure
python3 -c "
import json, sys

diff_content = open('$WORKDIR/diff.patch', 'r', errors='ignore').read() if open('$WORKDIR/diff.patch').name else ''
files = []
current_file = None
current_lines = []

for line in diff_content.splitlines():
    if line.startswith('diff --git'):
        if current_file:
            files.append({'path': current_file, 'diff': '\n'.join(current_lines)})
        parts = line.split()
        current_file = parts[-1].lstrip('b/') if len(parts) >= 4 else 'unknown'
        current_lines = [line]
    else:
        current_lines.append(line)

if current_file:
    files.append({'path': current_file, 'diff': '\n'.join(current_lines)})

with open('$WORKDIR/diffs.json', 'w') as f:
    json.dump(files, f, indent=2)
"

# Build context.json
python3 -c "
import json, re

try:
    mr = json.load(open('$WORKDIR/mr.json'))
except Exception:
    mr = {}

title = mr.get('title', '')
body = mr.get('body', '')
text = f'{title} {body}'

# Ticket key extraction (e.g. JIRA-1234, PROJ-56)
ticket_keys = re.findall(r'[A-Z][A-Z0-9]+-\d+', text)

context = {
    'head_sha': mr.get('headRefOid', 'HEAD'),
    'base_sha': mr.get('baseRefOid', 'origin/main'),
    'ticket_keys': list(set(ticket_keys)),
    'file_signals': {
        'skip_lanes': []
    }
}

with open('$WORKDIR/context.json', 'w') as f:
    json.dump(context, f, indent=2)
"
