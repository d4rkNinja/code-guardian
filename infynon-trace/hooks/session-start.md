# Session Start Hook

## Purpose

Ground the agent in validated codebase knowledge before work begins. Invoke the tracer agent to present a memory overview and let the user choose which layers to load.

## Trigger

- New session starts (`startup` or `resume`)
- Fires via `SessionStart` hook in `.claude/settings.json`

## What the Hook Does

The hook runs these commands automatically:

```bash
# 1. Always show canonical memory
infynon trace retrieve --layer canonical --format markdown

# 2. Show team memory index (first 20 lines)
infynon trace retrieve --layer team --format markdown --limit 5

# 3. Show user memory index (first 10 lines)
infynon trace retrieve --layer user --format markdown --limit 5
```

The output is injected into Claude's context. Claude then invokes `@tracer` to handle the interactive part.

## Tracer Agent Sequence

After the hook injects the overview, `@tracer`:

```
1. PRESENT the memory overview to the user
   → "Here's what's in memory. Which layers would you like to load?"
   → [c] Canonical only (always loaded)
   → [t] + Team memory
   → [u] + User memory
   → [a] All layers
   → [n] Skip additional layers

2. LOAD chosen layers with commands:
   If team:  infynon trace retrieve --layer team --format markdown
   If user:  infynon trace retrieve --layer user --author <current-user> --format markdown
   If sync:  infynon trace sync --direction pull

3. CONFIRM what was loaded:
   → "Loaded: canonical ✓  team ✓  user ✗ — ready."

4. HAND OFF to main session — do not block work
```

## Example Output

```
=== INFYNON TRACE: MEMORY OVERVIEW ===

--- Canonical Memory ---
[canonical] arch-auth-middleware: "Auth uses middleware pattern"
[canonical] security-token-signing: "Tokens are RS256 signed"
[canonical] arch-error-handling: "All errors use InfynonError enum"

--- Team Memory Index ---
[team] caveat-payment-legacy: "Don't refactor legacy payment module"
[team] handoff-payment-v2: "Payment V2 handoff — webhook incomplete"
[team] pr-142-context: "Auth refresh moved to middleware"
... (7 notes total)

--- User Memory Index ---
[user] reminder-flaky-ci: "Investigate flaky test in CI"
... (2 notes total)

Which layers to load? [c/t/u/a/n]:
```

## Rules

- Canonical is always loaded — no opt-out
- Never auto-load team or user memory without asking
- If `infynon trace` is not initialized, prompt: `infynon trace init`
- If no notes exist yet, inform user and continue immediately
- Do not block the session — once layers are chosen, proceed
