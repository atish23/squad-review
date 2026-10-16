#!/usr/bin/env python3
"""
precedents.py: Scans historical review comments from data/squad-comments.json
and surfaces past review discussions on the same files, packages, or classes.
"""

import sys
import json
import os
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("Usage: precedents.py <diffs.json>", file=sys.stderr)
        sys.exit(1)
        
    diffs_path = sys.argv[1]
    with open(diffs_path, "r", encoding="utf-8", errors="ignore") as f:
        diff_files = json.load(f)
        
    changed_paths = {item.get("path") for item in diff_files if item.get("path")}
    
    # Locate data/squad-comments.json
    script_dir = Path(__file__).resolve().parent
    corpus_path = script_dir.parent / "data" / "squad-comments.json"
    
    if not corpus_path.exists():
        print("No historical comment corpus found at data/squad-comments.json.")
        return
        
    try:
        with open(corpus_path, "r", encoding="utf-8", errors="ignore") as f:
            corpus = json.load(f)
    except Exception as e:
        print(f"Failed to parse corpus: {e}", file=sys.stderr)
        return
        
    print("=== Historical Review Precedents ===")
    matches = 0
    for comment in corpus:
        c_path = comment.get("path", "")
        # Check for path or basename overlap
        if any(c_path.endswith(os.path.basename(p)) for p in changed_paths):
            matches += 1
            author = comment.get("author", "Senior Engineer")
            body = comment.get("body", "").replace("\n", " ")
            rule = comment.get("rule_id", "GENERAL")
            print(f"- [{rule}] {c_path}:{comment.get('line', 0)} ({author}): \"{body}\"")
            
    if matches == 0:
        print("No historical precedent comments found for these files.")

if __name__ == "__main__":
    main()
