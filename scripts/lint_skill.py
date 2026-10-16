#!/usr/bin/env python3
"""
lint_skill.py: Validates skill configuration, rule catalogue consistency,
learnings schema, and directory integrity. Run after every modification.
"""

import sys
import json
import re
from pathlib import Path

REQUIRED_FILES = [
    "SKILL.md",
    "review-rules.md",
    "voice.md",
    "mindmap.md",
    "lane-contract.md",
    "agents/code.md",
    "agents/design.md",
    "agents/tests.md",
    "agents/precedents.md",
    "agents/security.md",
    "agents/verifier.md",
    "scripts/prepare.sh",
    "scripts/annotate_diff.py",
    "scripts/precedents.py"
]

def check_missing_files(root: Path):
    errors = 0
    for rel_path in REQUIRED_FILES:
        target = root / rel_path
        if not target.exists():
            print(f"[FAIL] Missing required file: {rel_path}")
            errors += 1
    return errors

def check_duplicate_rules(root: Path):
    rules_file = root / "review-rules.md"
    if not rules_file.exists():
        return 0
    
    errors = 0
    seen_ids = {}
    content = rules_file.read_text(encoding="utf-8", errors="ignore")
    rule_matches = re.finditer(r"### ([A-Z]{3}-\d{3}):\s*(.+)", content)
    
    for match in rule_matches:
        rule_id = match.group(1)
        name = match.group(2)
        if rule_id in seen_ids:
            print(f"[FAIL] Duplicate rule ID found: {rule_id} ('{name}' vs '{seen_ids[rule_id]}')")
            errors += 1
        else:
            seen_ids[rule_id] = name
            
    print(f"[OK] Checked {len(seen_ids)} rules in review-rules.md")
    return errors

def check_learnings_file(root: Path):
    learnings_file = root / "data" / "learnings.json"
    if not learnings_file.exists():
        print("[WARN] data/learnings.json does not exist (run setup to initialize)")
        return 0
        
    try:
        data = json.loads(learnings_file.read_text(encoding="utf-8"))
        if not isinstance(data, list):
            print("[FAIL] data/learnings.json must contain a JSON array")
            return 1
        print(f"[OK] data/learnings.json parsed cleanly ({len(data)} entries)")
    except Exception as e:
        print(f"[FAIL] Malformed JSON in data/learnings.json: {e}")
        return 1
    return 0

def main():
    root = Path(__file__).resolve().parent.parent
    print(f"Linting squad-review repository at {root}...")
    
    errors = 0
    errors += check_missing_files(root)
    errors += check_duplicate_rules(root)
    errors += check_learnings_file(root)
    
    # Check for stray backup files
    bak_files = list(root.glob("**/*.bak"))
    if bak_files:
        print(f"[WARN] Found {len(bak_files)} stray .bak files:")
        for bf in bak_files:
            print(f"  {bf.relative_to(root)}")
            
    if errors > 0:
        print(f"\nLint completed with {errors} error(s). Please fix before committing.")
        sys.exit(1)
    else:
        print("\nAll skill checks passed successfully!")

if __name__ == "__main__":
    main()
