#!/usr/bin/env bash
# Installs Trace session hooks into the current project's .claude/settings.json
# Usage: bash install.sh [project-dir]
# If no project-dir is given, uses current working directory.

set -euo pipefail

PROJECT_DIR="${1:-.}"
SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/settings-template.json"

if [ ! -f "$TEMPLATE" ]; then
  echo "[trace] ERROR: settings-template.json not found at $TEMPLATE"
  exit 1
fi

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hooks already exist
  if grep -q "trace-hook" "$SETTINGS_FILE" 2>/dev/null; then
    echo "[trace] Hooks already installed in $SETTINGS_FILE"
    exit 0
  fi

  # Merge: if settings.json exists but has no hooks, add them
  if command -v jq &>/dev/null; then
    # Use jq to merge if available
    EXISTING=$(cat "$SETTINGS_FILE")
    TRACE_HOOKS=$(jq '.hooks' "$TEMPLATE")

    if echo "$EXISTING" | jq -e '.hooks' &>/dev/null; then
      # Existing hooks — merge arrays
      echo "$EXISTING" | jq --argjson trace "$TRACE_HOOKS" '
        .hooks.SessionStart = (.hooks.SessionStart // []) + ($trace.SessionStart // []) |
        .hooks.Stop = (.hooks.Stop // []) + ($trace.Stop // [])
      ' > "$SETTINGS_FILE"
    else
      # No existing hooks — add the hooks key
      echo "$EXISTING" | jq --argjson trace "$TRACE_HOOKS" '. + {hooks: $trace}' > "$SETTINGS_FILE"
    fi
    echo "[trace] Hooks merged into existing $SETTINGS_FILE"
  else
    echo "[trace] WARNING: jq not found. Cannot merge with existing settings."
    echo "[trace] Please manually add the hooks from settings-template.json to $SETTINGS_FILE"
    exit 1
  fi
else
  # No existing settings — copy template directly
  cp "$TEMPLATE" "$SETTINGS_FILE"
  echo "[trace] Hooks installed at $SETTINGS_FILE"
fi

echo "[trace] Session hooks are now active:"
echo "  - SessionStart: loads canonical memory, asks about team memory"
echo "  - Stop: reminds to save observations and compact"
echo ""
echo "[trace] To remove hooks, delete the trace entries from $SETTINGS_FILE"
