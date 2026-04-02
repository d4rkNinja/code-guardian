# Canonical Memory Management — Trace Skill

## When to Use

Activate this skill when:

- User asks about "truth memory", "canonical memory", or "validated knowledge"
- User wants to store architecture decisions or API contracts
- User asks what's safe to trust in the codebase
- User wants to promote a note to the highest trust level
- User needs to audit or validate existing canonical notes

## What Is Canonical Memory

Canonical memory is the **smallest, most durable** layer in Trace's three-tier system. It stores knowledge that has been deliberately validated and is intended to be trusted across the team.

**Not all memory should be treated equally.** "Truth memory which is always correct" is too strong a promise. Even canonical memory can become outdated when code changes. Use "canonical" or "validated" — never promise "always correct."

## What Belongs in Canonical

| Category | Example |
|----------|---------|
| Architecture decisions | "All auth flows go through middleware" |
| Stable API contracts | "POST /users returns 201 with Location header" |
| Config invariants | "Rate limit is always per-IP, never global-only" |
| Known security constraints | "Tokens are RS256 signed, never HS256" |
| Canonical module facts | "Error handling uses InfynonError enum via thiserror" |
| Migration rules | "All DB migrations must be backwards-compatible for 2 releases" |

## What Does NOT Belong in Canonical

- Active caveats or temporary workarounds → **team memory**
- Personal observations or unfinished thoughts → **user memory**
- Branch-specific context → **team memory with branch scope**
- Anything that hasn't been validated across at least one merge
- Anything that changes frequently

## Promotion Rules

A note should only enter canonical after:

1. **Merge** — the related code has landed in main
2. **Validation** — someone has verified the note matches current code
3. **Manual review** — a human has approved the promotion
4. **Repeated reuse without contradiction** — the note has been referenced multiple times without anyone correcting it

## Promotion Workflow

### Step 1: Identify a candidate

```bash
# Find notes tagged for promotion
infynon trace retrieve --tag promote

# Or find long-lived, frequently-referenced team notes
infynon trace retrieve --layer team --tag architecture
```

### Step 2: Validate against current state

Before promoting, verify:
- Is the code still structured this way?
- Has the API contract changed?
- Are there any PRs that contradict this?
- When was the note last updated?

### Step 3: Create the canonical note

```bash
infynon trace note add canonical-<topic> \
  --title "<Clear, factual statement>" \
  --body "<Details with validation evidence. Include: which PRs validated this, since which version, any constraints.>" \
  --layer canonical \
  --scope repo \
  --tags <relevant-tags>
```

### Step 4: Archive the source note

```bash
infynon trace note update <original-id> --status archived
```

## Canonical Note Template

Every canonical note should include in its body:

```
<Factual statement>

Validated: PRs #X, #Y, #Z
Stable since: vX.Y.Z
Constraints: <any conditions under which this might change>
Last verified: <date>
```

## Auditing Canonical Memory

Canonical notes can go stale. Regularly audit:

```bash
# List all canonical notes
infynon trace retrieve --layer canonical

# Check for stale canonical notes
infynon trace retrieve --layer canonical --tag stale
```

For each canonical note, ask:
1. Is this still true in the current codebase?
2. Has the code it references changed since `updated_at`?
3. Are there any contradicting team or user notes?

If stale:
```bash
# Mark as stale for review
infynon trace note update <id> --status stale

# Or archive if no longer valid
infynon trace note update <id> --status archived
```

## Tips

- Keep canonical memory small — 10-20 notes for a medium project is healthy
- Every canonical note should be something a new team member needs to know on day one
- If you're unsure whether something is canonical, it's probably team memory
- Run `infynon trace retrieve --layer canonical` at session start to ground yourself
- Use SQL backends for canonical — they're durable, auditable, and queryable
