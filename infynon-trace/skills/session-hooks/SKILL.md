---
name: session-hooks
description: Configure and run INFYNON Trace session hooks for automatic memory loading and saving. Install only when user explicitly asks — hooks go in project .claude/settings.json, never system-level.
disable-model-invocation: true
---

# Session Hooks — Trace Skill

## When to Use

Activate this skill when:

- A new coding session starts (user opens Claude Code, starts work)
- A coding session ends (user is wrapping up, about to close)
- User asks about "session hooks", "memory hooks", or "auto-load memory"
- User wants to configure automatic memory loading/saving behavior

## Overview

Session hooks are the automated entry and exit points for Trace's memory operating layer. They ensure that:

- **On session start:** The `@tracer` agent is invoked, presents the memory overview, and asks the user which layers to load before work begins
- **On session end:** The `@tracer` agent auto-saves the session to user memory (no prompt), then asks the user if team memory should be updated too

## Installing Hooks (User Must Explicitly Ask)

Hooks are **opt-in only**. When the user asks to set up trace hooks, install them into the **project's** `.claude/settings.json` (never system-level).

### Option 1: Run the install script

```bash
bash <path-to-code-guardian>/infynon-trace/hooks/install.sh <project-dir>
```

This creates or merges hooks into `<project-dir>/.claude/settings.json`.

### Option 2: Write settings.json directly

Create `.claude/settings.json` in the project root:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== INFYNON TRACE: MEMORY OVERVIEW ===' && infynon trace retrieve --layer canonical --format markdown 2>/dev/null || echo '[trace] Not initialized. Run: infynon trace init' && echo '' && echo '--- Team Memory Index ---' && infynon trace retrieve --layer team --format markdown --limit 5 2>/dev/null || echo '(no team notes)' && echo '' && echo '--- User Memory Index ---' && infynon trace retrieve --layer user --format markdown --limit 5 2>/dev/null || echo '(no user notes)' && echo '' && echo '[TRACE-HOOK] Invoke @tracer agent. Ask the user which memory layers to load before proceeding with the session.'",
            "timeout": 20
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "INPUT=$(cat); if [ \"$(echo \"$INPUT\" | jq -r '.stop_hook_active // false')\" = \"true\" ]; then exit 0; fi; echo '[TRACE-HOOK] Task complete. Invoke @tracer agent to: (1) Auto-save session observations to user memory using infynon trace note add --layer user --tags session-output,auto-saved — no prompt needed. (2) Run infynon trace compact. (3) Ask user if highlights should also be saved to team memory.'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### What the hooks do

- **SessionStart:** Runs `infynon trace retrieve` for all layers, injects the memory overview into Claude's context, and instructs Claude to invoke `@tracer` to ask the user which layers to load.
- **Stop:** Checks `stop_hook_active` to prevent infinite loops. When work is complete, instructs `@tracer` to auto-save to user memory (no prompt) and ask about team memory.

### Important

- Hooks go in the **project** `.claude/settings.json`, not `~/.claude/settings.json`
- If `.claude/settings.json` already exists, the install script merges (requires `jq`)
- The user must explicitly ask to install hooks — never auto-install
- To remove hooks, delete the trace entries from `.claude/settings.json`

## Session Start Hook

### Flow

```
Session Start
    │
    ├── 1. Load canonical memory (always)
    │       infynon trace retrieve --layer canonical --format markdown
    │
    ├── 2. Ask user: "Load team memory?"
    │       ├── Yes → infynon trace retrieve --layer team --format markdown
    │       └── No  → skip
    │
    ├── 3. (Optional) Load user memory
    │       infynon trace retrieve --layer user --author <current-user> --format markdown
    │
    └── 4. Pull from remote if configured
            infynon trace sync --direction pull
```

### Implementation

**Step 1: Load canonical memory (non-negotiable)**

Canonical memory contains architecture decisions, API contracts, and security constraints. The agent must always know these before making changes.

```bash
infynon trace retrieve --layer canonical --format markdown
```

Review the output. These are the ground rules for this codebase.

**Step 2: Ask about team memory**

Team memory contains active caveats, handoffs, and working knowledge. It's useful but can be noisy.

> Ask the user: "Do you want to load team memory for this session?"

If yes:
```bash
infynon trace retrieve --layer team --format markdown
```

If the user says no, that's fine — team memory is optional at session start.

**Step 3: Optionally load user memory**

If the user has personal notes from a previous session:
```bash
infynon trace retrieve --layer user --author <username> --format markdown
```

**Step 4: Pull from remote**

If a remote backend is configured, sync to get the latest notes:
```bash
infynon trace sync --direction pull
```

## Session End Hook

### Flow

```
Session End
    │
    ├── 1. Ask user: "Any observations to save?"
    │       ├── Yes → Create team/user notes
    │       └── No  → skip
    │
    ├── 2. Mark session-scoped notes as stale
    │       infynon trace note update <id> --status stale
    │
    ├── 3. Flag promotion candidates
    │       Any team note reused 3+ times without contradiction
    │
    ├── 4. Compact stale and session notes
    │       infynon trace compact
    │
    ├── 5. Push to remote if configured
    │       infynon trace sync --direction push
    │
    └── 6. NEVER auto-update canonical memory
```

### Implementation

**Step 1: Capture new observations**

Ask the user if they learned anything worth saving:

> "Did you discover anything during this session worth noting? (Architecture changes, caveats, handoff notes, bugs found)"

If yes, create notes in the appropriate layer:

```bash
# Team observation
infynon trace note add session-obs-<topic> \
  --title "<What was learned>" \
  --body "<Details and context>" \
  --layer team \
  --scope <appropriate-scope> \
  --tags session-output

# Personal note
infynon trace note add user-obs-<topic> \
  --title "<Personal observation>" \
  --body "<Details>" \
  --layer user \
  --author <username>
```

**Step 2: Update stale notes**

If any notes loaded at session start are now outdated:

```bash
infynon trace note update <id> --status stale
```

**Step 3: Flag promotion candidates**

If a team note was referenced multiple times this session and remains accurate:

```bash
infynon trace note update <id> --tags promote,canonical-candidate
```

**Step 4: Compact**

Clean up session-scoped and stale notes:

```bash
infynon trace compact
```

**Step 5: Push to remote**

```bash
infynon trace sync --direction push
```

**Step 6: Never auto-update canonical**

Even if the agent discovered something important, canonical updates require human review. At most, flag it:

```bash
infynon trace note add promote-<topic> \
  --title "Promote candidate: <topic>" \
  --body "Discovered during session. Needs validation before canonical promotion." \
  --layer team \
  --tags promote,needs-review
```

## Hook Configuration

### Reference: settings.json (full config)

The canonical hook configuration — same as Option 2 above, kept here for reference:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== INFYNON TRACE: MEMORY OVERVIEW ===' && infynon trace retrieve --layer canonical --format markdown 2>/dev/null || echo '[trace] Not initialized. Run: infynon trace init' && echo '' && echo '--- Team Memory Index ---' && infynon trace retrieve --layer team --format markdown --limit 5 2>/dev/null || echo '(no team notes)' && echo '' && echo '--- User Memory Index ---' && infynon trace retrieve --layer user --format markdown --limit 5 2>/dev/null || echo '(no user notes)' && echo '' && echo '[TRACE-HOOK] Invoke @tracer agent. Ask the user which memory layers to load before proceeding.'",
            "timeout": 20
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "INPUT=$(cat); if [ \"$(echo \"$INPUT\" | jq -r '.stop_hook_active // false')\" = \"true\" ]; then exit 0; fi; echo '[TRACE-HOOK] Task complete. Invoke @tracer agent to: (1) Auto-save session to user memory using infynon trace note add --layer user --tags session-output,auto-saved — no prompt needed. (2) Run infynon trace compact. (3) Ask user if highlights should also be saved to team memory.'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### Manual Invocation (no hooks installed)

If hooks are not configured, the agent should:

1. At session start — be explicitly invoked (`@tracer`) and run the session start workflow
2. When the user says "done", "wrapping up", "end session" — run the session end workflow manually

## Rules

- **Canonical memory is always loaded** — no exceptions, no user opt-out for this layer
- **Session start: ask before loading team/user** — present overview, wait for user choice
- **Session end: auto-save user memory** — always, no prompt required
- **Session end: ask before team memory** — opt-in only
- **NEVER write canonical at session end** — flag candidates only
- **Compaction always runs at end** — keeps storage clean
- **Stop hook checks stop_hook_active** — prevents infinite loops
- **Sync direction matters** — pull at start, push at end
- **If no backend configured** — use local file storage, skip sync steps

## Tips

- If the session is short (quick fix), skip the full hook workflow
- If the user is investigating a bug, load team notes tagged with the affected module
- If the user is doing a code review, load PR-scoped notes for that PR
- Tag session-output notes so they can be easily found and promoted later
- Don't over-save — only create notes for things that would be useful in a future session
