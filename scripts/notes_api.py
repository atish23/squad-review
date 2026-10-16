#!/usr/bin/env python3
"""
notes_api.py: Wrapper for GitHub/GitLab REST API calls to manage PR line comments.
Prevents shell escaping issues with special characters and backticks.
"""

import sys
import json
import os
import argparse
import urllib.request
import urllib.error

def post_github_comment(repo, pr_number, token, file_path, line, body):
    url = f"https://api.github.com/repos/{repo}/pulls/{pr_number}/comments"
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json",
        "User-Agent": "squad-review-skill"
    }
    payload = {
        "body": body,
        "path": file_path,
        "line": line,
        "side": "RIGHT"
    }
    req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
    with urllib.request.urlopen(req) as resp:
        res = json.loads(resp.read().decode("utf-8"))
        print(f"POSTED {res.get('html_url', '')}#note_{res.get('id', '')}")

def main():
    parser = argparse.ArgumentParser(description="Manage Git PR comments safely")
    parser.add_argument("--action", choices=["post", "edit", "delete"], required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--pr", required=True)
    parser.add_argument("--file")
    parser.add_argument("--line", type=int)
    parser.add_argument("--body")
    parser.add_argument("--note-id")
    
    args = parser.parse_args()
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    
    if not token:
        print("Error: GITHUB_TOKEN environment variable required for direct API calls", file=sys.stderr)
        sys.exit(1)
        
    if args.action == "post":
        if not args.file or not args.line or not args.body:
            print("Error: --file, --line, and --body required for post action", file=sys.stderr)
            sys.exit(1)
        post_github_comment(args.repo, args.pr, token, args.file, args.line, args.body)

if __name__ == "__main__":
    main()
