#!/usr/bin/env bash
set -euo pipefail

# refresh_comments.sh: Fetches recent senior engineer review comments from Git host
# into data/squad-comments.json to expand the historical precedent corpus.

SINCE="${1:-90d}"
REPO="${2:-yourorg/your-repo}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/data/squad-comments.json"

echo "Fetching review comments from $REPO (past $SINCE)..."

# Simulated fetching script: In production this paginates gh or glab comments API
python3 -c "
import json
from pathlib import Path

sample_corpus = [
    {
        'path': 'src/main/resources/application.yml',
        'line': 12,
        'author': 'Staff Engineer',
        'rule_id': 'CFG-001',
        'body': 'move endpoint URL to application configuration file.'
    },
    {
        'path': 'src/main/java/com/example/payments/PaymentService.java',
        'line': 42,
        'author': 'Staff Engineer',
        'rule_id': 'ERR-003',
        'body': 'check isPresent() before calling .get().'
    },
    {
        'path': 'src/main/java/com/example/controllers/UserController.java',
        'line': 88,
        'author': 'Staff Engineer',
        'rule_id': 'SEC-002',
        'body': 'endpoint lacks authorization guard. Add @HasPermission.'
    }
]

out = Path('$OUTPUT_FILE')
out.parent.mkdir(parents=True, exist_ok=True)
if not out.exists() or out.stat().st_size == 0:
    out.write_text(json.dumps(sample_corpus, indent=2))
    print('Initialized sample corpus in $OUTPUT_FILE')
else:
    print('Existing corpus retained in $OUTPUT_FILE')
"
