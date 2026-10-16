#!/usr/bin/env bash
set -euo pipefail

# squad-review interactive installer
echo "=== Installing squad-review Skill ==="

# Default Claude directories
CLAUDE_DIR="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills/squad-review"
AGENTS_DIR="${CLAUDE_DIR}/agents"

mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Copying skill orchestrator and rule files to $SKILLS_DIR..."
cp "$SCRIPT_DIR/SKILL.md" "$SKILLS_DIR/"
cp "$SCRIPT_DIR/review-rules.md" "$SKILLS_DIR/"
cp "$SCRIPT_DIR/voice.md" "$SKILLS_DIR/"
cp "$SCRIPT_DIR/mindmap.md" "$SKILLS_DIR/"
cp "$SCRIPT_DIR/lane-contract.md" "$SKILLS_DIR/"

echo "Copying scripts to $SKILLS_DIR/scripts..."
mkdir -p "$SKILLS_DIR/scripts"
cp -r "$SCRIPT_DIR/scripts/"* "$SKILLS_DIR/scripts/"
chmod +x "$SKILLS_DIR/scripts/"*.sh "$SKILLS_DIR/scripts/"*.py

echo "Initializing data directory at $SKILLS_DIR/data..."
mkdir -p "$SKILLS_DIR/data/reviewed"
if [[ ! -f "$SKILLS_DIR/data/learnings.json" ]]; then
  echo "[]" > "$SKILLS_DIR/data/learnings.json"
fi
if [[ ! -f "$SKILLS_DIR/data/squad-comments.json" ]]; then
  cp "$SCRIPT_DIR/data/squad-comments.json" "$SKILLS_DIR/data/"
fi

echo "Copying sub-agents to $AGENTS_DIR..."
for agent in "$SCRIPT_DIR/agents/"*.md; do
  agent_name=$(basename "$agent")
  cp "$agent" "$AGENTS_DIR/squad-review-${agent_name}"
done

echo "Running linter to verify installation integrity..."
python3 "$SKILLS_DIR/scripts/lint_skill.py"

echo ""
echo "Installation complete!"
echo "Restart your Claude or Antigravity session so the new agents load."
