# Memory Operations — Trace Skill

## When to Use

Activate this skill when:

- User asks about coding memory, shared notes, or repo context
- User wants to store, retrieve, or update knowledge about the codebase
- User mentions handoffs, PR notes, architecture decisions, or team knowledge
- User asks about canonical memory, team memory, or user memory
- User wants to set up a memory backend (Redis or SQL)
- User asks about Trace or `infynon trace`
- `.infynon/trace/config.toml` is detected in the project

## Critical Rules

1. **Layer discipline.** Always place notes in the correct layer:
   - **Canonical** — architecture decisions, API contracts, config invariants, security constraints, module facts, migration rules
   - **Team** — active caveats, branch notes, handoffs, PR summaries, risky areas, unresolved issues
   - **User** — personal reminders, local observations, unfinished thoughts, task context
2. **Never auto-create canonical notes.** Canonical notes are promoted, not auto-written.
3. **Always resolve default user** from `infynon trace` config when `--author` is not specified.
4. **Every note should track provenance:** source commit, status, confidence, updated_at.

## Prerequisites

```bash
infynon --version
```

If not installed:
```bash
npm install -g infynon
```

## Initialize Trace

```bash
# Initialize with repo identity
infynon trace init --repo <repo-name> --owner <team-name> --user <username>

# Add a SQL backend (recommended for canonical + team memory)
infynon trace source add-sql team-db \
  --engine sqlite \
  --url sqlite://.infynon/trace/trace.db \
  --user <username> \
  --default

# Or add Redis for fast session-style coordination
infynon trace source add-redis team-redis \
  --url redis://localhost:6379/0 \
  --namespace infynon \
  --user <username>
```

## Command Reference by User Intent

### "I want to store a note about the codebase"

```bash
# Team-level note (most common)
infynon trace note add <id> \
  --title "Description" \
  --body "Details" \
  --layer team \
  --scope repo

# Branch-specific handoff
infynon trace note add <id> \
  --title "Handoff note" \
  --body "What the next person needs to know" \
  --layer team \
  --scope branch \
  --target feature/my-branch \
  --tags handoff

# PR-linked note
infynon trace note add <id> \
  --title "PR context" \
  --body "Why this change was made" \
  --layer team \
  --scope pr \
  --target 142 \
  --related-pr 142

# File-scoped note
infynon trace note add <id> \
  --title "Watch out" \
  --body "This module has a known race condition" \
  --layer team \
  --scope file \
  --target src/auth.rs \
  --files src/auth.rs \
  --tags caveat,race-condition

# Package note (who introduced a risky dependency)
infynon trace note add <id> \
  --title "chrono added" \
  --body "Added for Trace sync timestamps. Low risk." \
  --layer user \
  --scope package \
  --target chrono
```

### "I want to find relevant notes"

```bash
# All canonical memory
infynon trace retrieve --layer canonical

# Team notes for current branch
infynon trace retrieve --layer team --scope branch --target <branch-name>

# Notes about a specific file
infynon trace retrieve --scope file --target src/auth.rs

# Notes by a specific author
infynon trace retrieve --author alien

# Notes with a specific tag
infynon trace retrieve --tag handoff

# Package notes
infynon trace retrieve --scope package --target chrono

# PR-linked notes
infynon trace retrieve --scope pr --target 142
```

### "I want to update or clean up notes"

```bash
# Mark a note as stale
infynon trace note update <id> --status stale

# Update note content
infynon trace note update <id> --title "New title" --body "Updated content"

# Remove a note
infynon trace note remove <id>

# Compact stale and session notes
infynon trace compact
```

### "I want to sync with a remote backend"

```bash
# Push local notes to remote
infynon trace sync --direction push

# Pull remote notes locally
infynon trace sync --direction pull

# Bidirectional sync
infynon trace sync --direction both

# Sync with a specific backend
infynon trace sync --source team-db --direction both
```

### "I want to promote a note to canonical"

Canonical notes are never auto-created. The promotion path:

1. Start as user or team note
2. Validate against current code state
3. Confirm the note has been stable (no contradictions across merges)
4. Create the canonical version

```bash
# Step 1: Flag for promotion
infynon trace note update my-note --tags promote,canonical-candidate

# Step 2: After review, create canonical note
infynon trace note add arch-<topic> \
  --title "Architectural decision: ..." \
  --body "Validated across PRs #x, #y. Stable since v0.x.x." \
  --layer canonical \
  --scope repo \
  --tags architecture

# Step 3: Archive the original team note
infynon trace note update my-note --status archived
```

### "I want to set up backends"

```bash
# List current backends
infynon trace source list

# Add SQLite (local, good for canonical + team)
infynon trace source add-sql local-db \
  --engine sqlite \
  --url sqlite://.infynon/trace/trace.db \
  --user <username> \
  --default

# Add PostgreSQL (shared team database)
infynon trace source add-sql team-db \
  --engine postgres \
  --url postgres://user:pass@db.example.com:5432/infynon \
  --user <username>

# Add Redis (fast session state)
infynon trace source add-redis session-redis \
  --url redis://localhost:6379/0 \
  --namespace infynon \
  --user <username>

# Set default backend
infynon trace source default team-db

# Remove a backend
infynon trace source remove old-source

# View backend schema
infynon trace schema sql
infynon trace schema redis
```

## Backend Selection Guide

| Use Case | Backend | Why |
|----------|---------|-----|
| Canonical memory | SQL (SQLite/Postgres) | Durable, auditable, structured queries |
| Team memory | SQL or Redis | SQL for history, Redis for live coordination |
| User memory | Local files or SQLite | Personal, low overhead |
| Session state | Redis | Fast, ephemeral, auto-expiring |
| CI/CD integration | SQL (Postgres) | Shared across runners, queryable |
| Multi-machine sync | Redis or Postgres | Network-accessible |

## Note Scopes

| Scope | Use For | Example Target |
|-------|---------|----------------|
| `repo` | Repository-wide facts | `current` |
| `branch` | Branch-specific context | `feature/auth-refresh` |
| `pr` | PR-linked notes | `142` |
| `file` | File-specific caveats | `src/auth.rs` |
| `user` | User-specific notes | `alien` |
| `session` | Temporary session context | `current` |
| `package` | Dependency provenance | `chrono` |

## TUI

```bash
infynon trace tui
```

**5 Tabs:**
| Key | Tab | Purpose |
|-----|-----|---------|
| 1 | Overview | Trace status, config summary, layer counts |
| 2 | Sources | Backend list, connection status, default indicator |
| 3 | Notes | Browse all notes, filter by layer/scope/status |
| 4 | Packages | Package findings with `installed_by` attribution |
| 5 | EditLog | History of note changes |

**TUI Keys:**
- `Tab` / `Shift+Tab` — navigate fields
- `Enter` — edit field
- `q` — quit
- Arrow keys — scroll and navigate

## Tips

- Use `--scope branch` for handoffs so they auto-associate with the branch lifecycle
- Use `--scope pr` with `--related-pr` to link notes to pull requests
- Tag notes with `promote` when they're candidates for canonical promotion
- Run `infynon trace compact` regularly to clean session and stale notes
- Use `--layer user` for personal scratch notes that shouldn't clutter team memory
- Canonical memory should be the smallest layer — resist the urge to canonicalize everything
