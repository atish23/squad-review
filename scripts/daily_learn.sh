#!/usr/bin/env bash
set -euo pipefail

# daily_learn.sh: Evaluates data/learnings.json against review-rules.md
# and drafts rule adjustments into data/skill-proposals.md for human review.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEARNINGS="$ROOT_DIR/data/learnings.json"
PROPOSALS="$ROOT_DIR/data/skill-proposals.md"

python3 -c "
import json
from pathlib import Path
from collections import Counter

learnings_path = Path('$LEARNINGS')
proposals_path = Path('$PROPOSALS')

if not learnings_path.exists():
    exit(0)

try:
    records = json.loads(learnings_path.read_text())
except Exception:
    records = []

rejected = [r for r in records if r.get('kind') == 'rejected']
rule_counts = Counter(r.get('rule') for r in rejected if r.get('rule'))

proposals = ['# Automated Skill Improvement Proposals', '', 'Review and merge these proposals manually. The skill never modifies its own rules.', '']

for rule, count in rule_counts.most_common():
    if count >= 2:
        proposals.append(f'## Proposal: Adjust Verification for {rule}')
        proposals.append(f'- **Rejections observed**: {count}')
        proposals.append(f'- **Recommendation**: Tighten verify step or demote weight to prevent repeated false alarms.')
        proposals.append('')

if len(proposals) == 4:
    proposals.append('No recurring rule rejections observed in recent reviews.')

proposals_path.write_text('\n'.join(proposals))
print(f'Updated proposals in {proposals_path}')
"
