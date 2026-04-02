# Session Hooks — Trace Skill

## When to Use

Activate this skill when:

- A new coding session starts (user opens Claude Code, starts work)
- A coding session ends (user is wrapping up, about to close)
- User asks about "session hooks", "memory hooks", or "auto-load memory"
- User wants to configure automatic memory loading/saving behavior

## Overview

Session hooks are the automated entry and exit points for Trace's memory operating layer. They ensure that:

- **On session start:** The agent is grounded in validated knowledge before writing any code
- **On session end:** New observations are captured and memory is kept clean

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
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== TRACE: Loading Canonical Memory ===' && infynon trace retrieve --layer canonical 2>/dev/null || echo '[trace] Not initialized. Run: infynon trace init --repo <name> --owner <team> --user <you>' && echo '---' && echo '[trace-hook] Canonical memory loaded. Ask user: \"Would you like to load team memory for this session?\" If yes, run: infynon trace retrieve --layer team'",
            "timeout": 15
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo '[trace-hook] Session ending. Remind user: \"Any observations worth saving? I can create team/user notes and run compaction.\" If user agrees, create notes with infynon trace note add, then run: infynon trace compact'",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### What the hooks do

- **SessionStart:** Runs `infynon trace retrieve --layer canonical` and injects the output into Claude's context. Then prompts Claude to ask the user about loading team memory.
- **Stop:** Injects a reminder for Claude to ask the user about saving observations and running compaction.

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
    │       infynon trace retrieve --layer canonical
    │
    ├── 2. Ask user: "Load team memory?"
    │       ├── Yes → infynon trace retrieve --layer team
    │       └── No  → skip
    │
    ├── 3. (Optional) Load user memory
    │       infynon trace retrieve --layer user --author <current-user>
    │
    └── 4. Pull from remote if configured
            infynon trace sync --direction pull
```

### Implementation

**Step 1: Load canonical memory (non-negotiable)**

Canonical memory contains architecture decisions, API contracts, and security constraints. The agent must always know these before making changes.

```bash
infynon trace retrieve --layer canonical
```

Review the output. These are the ground rules for this codebase.

**Step 2: Ask about team memory**

Team memory contains active caveats, handoffs, and working knowledge. It's useful but can be noisy.

> Ask the user: "Do you want to load team memory for this session?"

If yes:
```bash
infynon trace retrieve --layer team
```

If the user says no, that's fine — team memory is optional at session start.

**Step 3: Optionally load user memory**

If the user has personal notes from a previous session:
```bash
infynon trace retrieve --layer user --author <username>
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

### Claude Code Settings Hook (settings.json)

To run session hooks automatically, configure in Claude Code settings:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "session_start",
        "command": "infynon trace retrieve --layer canonical"
      }
    ],
    "PostToolUse": [],
    "Notification": [],
    "Stop": [
      {
        "matcher": "",
        "command": "infynon trace compact"
      }
    ]
  }
}
```

### Manual Hook Invocation

If hooks are not configured, the agent should:

1. At conversation start, run the session start workflow
2. When the user says "done", "wrapping up", or "end session", run the session end workflow

## Rules

- **Canonical memory is always loaded** — no exceptions, no user opt-out for this layer
- **Team memory is opt-in at start** — ask the user, respect their answer
- **User memory is personal** — only load for the current user
- **Session end never writes canonical** — only team and user layers
- **Compaction runs at end** — keeps storage clean
- **Sync direction matters** — pull at start, push at end
- **If no backend is configured** — use local file storage, skip sync steps

## Tips

- If the session is short (quick fix), skip the full hook workflow
- If the user is investigating a bug, load team notes tagged with the affected module
- If the user is doing a code review, load PR-scoped notes for that PR
- Tag session-output notes so they can be easily found and promoted later
- Don't over-save — only create notes for things that would be useful in a future session
