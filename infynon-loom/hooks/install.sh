#!/usr/bin/env bash
# Installs Loom session hooks into the current project's .claude/settings.json
# Usage: bash install.sh [project-dir]
# If no project-dir is given, uses current working directory.

set -euo pipefail

PROJECT_DIR="${1:-.}"
SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/settings-template.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "[loom] ERROR: settings-template.json not found at $TEMPLATE"
  exit 1
fi

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hooks already exist
  if grep -q "loom-hook" "$SETTINGS_FILE" 2>/dev/null; then
    echo "[loom] Hooks already installed in $SETTINGS_FILE"
    exit 0
  fi

  # Merge: if settings.json exists but has no hooks, add them
  if command -v jq &>/dev/null; then
    # Use jq to merge if available
    EXISTING=$(cat "$SETTINGS_FILE")
    LOOM_HOOKS=$(jq '.hooks' "$TEMPLATE")

    if echo "$EXISTING" | jq -e '.hooks' &>/dev/null; then
      # Existing hooks — merge arrays
      echo "$EXISTING" | jq --argjson loom "$LOOM_HOOKS" '
        .hooks.SessionStart = (.hooks.SessionStart // []) + ($loom.SessionStart // []) |
        .hooks.Stop = (.hooks.Stop // []) + ($loom.Stop // [])
      ' > "$SETTINGS_FILE"
    else
      # No existing hooks — add the hooks key
      echo "$EXISTING" | jq --argjson loom "$LOOM_HOOKS" '. + {hooks: $loom}' > "$SETTINGS_FILE"
    fi
    echo "[loom] Hooks merged into existing $SETTINGS_FILE"
  else
    echo "[loom] WARNING: jq not found. Cannot merge with existing settings."
    echo "[loom] Please manually add the hooks from settings-template.json to $SETTINGS_FILE"
    exit 1
  fi
else
  # No existing settings — copy template directly
  cp "$TEMPLATE" "$SETTINGS_FILE"
  echo "[loom] Hooks installed at $SETTINGS_FILE"
fi

echo "[loom] Session hooks are now active:"
echo "  - SessionStart: loads canonical memory, asks about team memory"
echo "  - Stop: reminds to save observations and compact"
echo ""
echo "[loom] To remove hooks, delete the loom entries from $SETTINGS_FILE"
