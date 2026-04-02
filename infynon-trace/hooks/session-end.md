# Session End Hook

## Purpose

When the main agent work completes: auto-save session observations to user memory (no prompt), then ask the user whether to also save to team memory.

## Trigger

- `Stop` hook fires (when Claude finishes responding)
- Fires every time Claude stops, but tracer only runs the full save workflow when `stop_hook_active` is false

## What the Hook Does

The hook outputs an instruction for Claude to invoke `@tracer`. The tracer agent runs the save workflow using CLI commands only.

## Tracer Agent Sequence

```
1. AUTO-SAVE to user memory (no prompt — always run this)
   → Summarize what was done during the session
   → Run: infynon trace note add session-<timestamp> \
         --title "<one-line summary of what was done>" \
         --body "<key changes, findings, context for next session>" \
         --layer user \
         --author <current-user> \
         --tags session-output,auto-saved \
         --scope session

2. COMPACT in background (cleanup stale notes)
   → infynon trace compact

3. ASK user:
   → "Session saved to your user memory. Save highlights to team memory too? [y/n]"

4. If YES — save to team memory:
   → Identify what's worth sharing: bugs found, caveats, handoffs, risky areas
   → Run: infynon trace note add team-<timestamp> \
         --title "<what the team needs to know>" \
         --body "<caveats, warnings, findings, handoff context>" \
         --layer team \
         --scope repo \
         --tags session-output

5. MARK stale notes:
   → Any notes that are now outdated after this session:
   → infynon trace note update <id> --status stale

6. FLAG promotion candidates (never write canonical directly):
   → If anything confirmed architectural facts:
   → infynon trace note add promote-<id> \
         --title "Promote candidate: <topic>" \
         --body "Confirmed during session. Needs validation before canonical." \
         --layer team \
         --tags promote,needs-review

7. SYNC if remote backend exists:
   → infynon trace sync --direction push
```

## What to Auto-Save to User Memory

Always capture without asking:
- What was worked on during the session
- Key files touched or investigated
- Any unfinished work to resume next time
- Personal reminders and observations

## What to Save to Team Memory (Only If User Says Yes)

Only save things the whole team benefits from:
- Bug discoveries: "Found a race condition in rate_limiter.rs"
- Caveats: "Don't upgrade serde past 1.0.200 — breaks custom deserializer"
- Handoff context: "Auth refactor half done — see src/middleware/"
- PR context: "PR #155 changes the error handling pattern"

## What NOT to Save

- Trivial observations already visible in code or git history
- Dead-end debugging paths
- Temporary workarounds being cleaned up in this session

## Rules

- **User memory auto-save is mandatory** — no opt-out, no prompt
- **Team memory is opt-in** — always ask before saving
- **NEVER write to canonical layer** during session end
- Tag all session-end notes with `session-output`
- `infynon trace compact` always runs at session end
- Skip sync step if no remote backend is configured
