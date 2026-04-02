# Session Start Hook

## Purpose

Ground the agent in validated codebase knowledge before any work begins.

## Trigger

- New conversation starts
- User opens a project
- Agent begins a new task

## Sequence

```
1. ALWAYS load canonical memory
   → infynon trace retrieve --layer canonical
   → These are non-negotiable ground rules

2. ASK user about team memory
   → "Would you like to load team memory for this session?"
   → If yes: infynon trace retrieve --layer team
   → If no: proceed without it

3. OPTIONALLY load user memory
   → infynon trace retrieve --layer user --author <default_user>
   → Only if user has personal notes from prior sessions

4. SYNC if remote backend exists
   → infynon trace sync --direction pull
   → Get latest notes from shared backends
```

## What Each Layer Provides

### Canonical (Always Loaded)
- Architecture decisions the agent must respect
- API contracts that must not be broken
- Security constraints that are non-negotiable
- Module facts that prevent wrong assumptions

### Team (User's Choice)
- Active caveats about dangerous areas
- Handoff notes from other developers
- PR summaries and branch context
- "Don't touch this" warnings
- Unresolved issues to be aware of

### User (Optional)
- Personal reminders from last session
- Unfinished investigation notes
- Local observations not yet shared

## Example Output

```
=== Canonical Memory (3 notes) ===
[canonical] arch-auth-middleware: "Auth uses middleware pattern"
[canonical] arch-error-handling: "All errors use InfynonError enum"
[canonical] security-token-signing: "Tokens are RS256 signed"

Load team memory? [y/n]: y

=== Team Memory (7 notes) ===
[team] caveat-payment-legacy: "Don't refactor legacy payment module"
[team] handoff-payment-v2: "Payment V2 handoff — webhook incomplete"
[team] pr-142-context: "Auth refresh moved to middleware"
...
```

## Rules

- Never skip canonical loading
- Never auto-load team memory without asking
- If `infynon trace` is not initialized, prompt user to run `infynon trace init`
- If no notes exist yet, inform user and continue
