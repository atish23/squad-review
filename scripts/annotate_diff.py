#!/usr/bin/env python3
"""
annotate_diff.py: Formats unified diff lines into old|new| marker syntax.
Enables agents to anchor comments to exact line coordinates.
"""

import sys
import json
import re

def annotate_file_diff(file_path, diff_text):
    print(f"=== File: {file_path} ===")
    old_line = 0
    new_line = 0
    
    for line in diff_text.splitlines():
        hunk_match = re.match(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@", line)
        if hunk_match:
            old_line = int(hunk_match.group(1))
            new_line = int(hunk_match.group(2))
            print(f"        |        | {line}")
            continue
            
        if line.startswith("+") and not line.startswith("+++"):
            print(f"        |{new_line:7d} | {line}")
            new_line += 1
        elif line.startswith("-") and not line.startswith("---"):
            print(f"{old_line:7d} |        | {line}")
            old_line += 1
        elif not line.startswith("diff ") and not line.startswith("index "):
            print(f"{old_line:7d} |{new_line:7d} | {line}")
            old_line += 1
            new_line += 1

def main():
    if len(sys.argv) < 2:
        print("Usage: annotate_diff.py <diffs.json>", file=sys.stderr)
        sys.exit(1)
        
    diffs_path = sys.argv[1]
    with open(diffs_path, "r", encoding="utf-8", errors="ignore") as f:
        files = json.load(f)
        
    for item in files:
        annotate_file_diff(item.get("path", "unknown"), item.get("diff", ""))

if __name__ == "__main__":
    main()
