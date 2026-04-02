# Session End Hook

## Purpose

Capture session learnings, clean up ephemeral notes, and sync state — without ever auto-writing canonical memory.

## Trigger

- User says "done", "wrapping up", "end session", or similar
- Conversation is ending
- Task is complete

## Sequence

```
1. ASK user about new observations
   → "Did you learn anything worth saving from this session?"
   → If yes: create team or user notes
   → If no: skip

2. UPDATE stale notes
   → Any notes loaded at start that are now outdated
   → infynon loom note update <id> --status stale

3. UPDATE team memory with session findings
   → Bug discoveries, caveats found, handoff updates
   → infynon loom note add <id> --layer team --tags session-output

4. FLAG promotion candidates
   → Notes reused without contradiction → tag with "promote"
   → infynon loom note update <id> --tags promote,canonical-candidate

5. COMPACT
   → infynon loom compact
   → Archives session-scoped and stale notes

6. SYNC to remote
   → infynon loom sync --direction push

7. NEVER auto-update canonical
   → At most, flag for review
```

## What to Save

### Worth Saving (Team Layer)
- Bug discoveries: "Found a race condition in rate_limiter.rs"
- Caveats: "Don't upgrade serde past 1.0.200 — breaks custom deserializer"
- Handoff context: "Auth refactor is half done — see src/middleware/"
- PR context: "PR #155 changes the error handling pattern"

### Worth Saving (User Layer)
- Personal reminders: "Need to investigate the flaky test in CI"
- Unfinished thoughts: "Might be able to simplify the sync logic"
- Task context: "Was working on the payment webhook handler"

### NOT Worth Saving
- Trivial observations already visible in code
- Debugging steps that led nowhere
- Temporary workarounds that will be cleaned up in this PR
- Anything that duplicates git history

## What to Update

### Mark as Stale
- Notes about code that was changed during this session
- Handoff notes for branches that were merged
- Caveats that were resolved

### Flag for Promotion
- Team notes that have been validated by code changes in this session
- Architecture patterns that were confirmed correct during debugging
- API contracts that were tested and held true

## Rules

- **NEVER write to canonical layer** during session end
- Only create notes the user explicitly approves
- Keep notes concise — future sessions load these
- Tag all session-end notes with `session-output` for traceability
- Run compact to keep storage clean
- If no remote backend, skip sync step
