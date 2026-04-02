# Loom Memory Workflows

## Example 1: New Project Setup

Set up Loom from scratch for a team repository.

```bash
# Initialize Loom
infynon loom init --repo my-api --owner backend-team --user alien

# Add SQLite for local canonical + team storage
infynon loom source add-sql local-db \
  --engine sqlite \
  --url sqlite://.infynon/loom/loom.db \
  --user alien \
  --default

# Add Redis for live session coordination (optional)
infynon loom source add-redis session-redis \
  --url redis://localhost:6379/0 \
  --namespace my-api \
  --user alien

# Create initial canonical notes
infynon loom note add arch-api-pattern \
  --title "REST API uses controller-service-repo pattern" \
  --body "All endpoints follow controller → service → repository. No direct DB access from controllers." \
  --layer canonical \
  --scope repo \
  --tags architecture,api

infynon loom note add arch-auth \
  --title "Auth uses JWT middleware" \
  --body "All authenticated routes go through auth middleware. Tokens are RS256 signed. Refresh via /auth/refresh." \
  --layer canonical \
  --scope repo \
  --tags architecture,auth
```

## Example 2: Branch Handoff

Developer A is handing off a feature branch to Developer B.

```bash
# Developer A creates handoff notes before switching
infynon loom note add handoff-payment-v2 \
  --title "Payment V2 handoff" \
  --body "Stripe integration is wired but webhook handler is incomplete. See src/payments/webhook.rs. The idempotency key logic needs testing against Stripe's test mode. Don't refactor the legacy payment module yet — it's still used by mobile." \
  --layer team \
  --scope branch \
  --target feature/payment-v2 \
  --files src/payments/webhook.rs,src/payments/stripe.rs \
  --tags handoff,payment,incomplete

infynon loom note add caveat-legacy-payment \
  --title "Don't refactor legacy payment module" \
  --body "Mobile app v3.2 still calls the legacy endpoint. Deprecation planned for Q3." \
  --layer team \
  --scope repo \
  --tags caveat,payment,do-not-touch

# Developer B retrieves handoff when picking up the branch
infynon loom retrieve --scope branch --target feature/payment-v2
infynon loom retrieve --tag handoff
```

## Example 3: PR-Linked Memory

Attach context to a pull request for reviewers and future reference.

```bash
# Before submitting PR
infynon loom note add pr-142-context \
  --title "PR #142: Auth refresh moved to middleware" \
  --body "Moved refresh token logic from individual route handlers into shared middleware. This changes the auth flow for all protected routes. The old handler functions are removed, not deprecated." \
  --layer team \
  --scope pr \
  --target 142 \
  --related-pr 142 \
  --files src/middleware/auth.rs,src/routes/auth.rs \
  --tags auth,refactor,breaking-change

# Reviewer can retrieve PR context
infynon loom retrieve --scope pr --target 142
```

## Example 4: Session Start / End Workflow

### Session Start

```bash
# 1. Always load canonical memory
infynon loom retrieve --layer canonical

# 2. Ask user: "Load team memory?"
# If yes:
infynon loom retrieve --layer team

# 3. Optionally load user memory
infynon loom retrieve --layer user --author alien
```

### During Session

```bash
# Capture observations as user-level notes
infynon loom note add obs-rate-limit-bug \
  --title "Rate limiter might leak under concurrent load" \
  --body "Noticed during load testing. Sliding window counter doesn't use atomic ops. Needs investigation." \
  --layer user \
  --scope file \
  --target src/rate_limiter.rs \
  --files src/rate_limiter.rs \
  --tags observation,bug-candidate

# Share with team when confident
infynon loom note add team-rate-limit-bug \
  --title "Rate limiter concurrent leak confirmed" \
  --body "Reproduced under 500 concurrent requests. Counter drifts by ~3%. Fix needed before v1.0." \
  --layer team \
  --scope file \
  --target src/rate_limiter.rs \
  --files src/rate_limiter.rs \
  --tags confirmed-bug,rate-limiter
```

### Session End

```bash
# 1. Review what was learned
infynon loom retrieve --layer user --author alien

# 2. Promote valuable observations to team
# (already done during session in this example)

# 3. Mark session notes as stale
infynon loom note update obs-rate-limit-bug --status stale

# 4. Compact
infynon loom compact

# 5. Sync to remote
infynon loom sync --direction push
```

## Example 5: Promoting to Canonical

A team note has been validated across multiple PRs and should become canonical.

```bash
# Check the existing team note
infynon loom retrieve --tag architecture

# Validate it's still accurate
# (read the code, check git log, confirm with team)

# Create canonical version
infynon loom note add canonical-error-handling \
  --title "All errors use thiserror + InfynonError enum" \
  --body "Error handling uses thiserror crate. All modules return InfynonError variants. Never use unwrap() in production paths. Validated across PRs #98, #112, #131. Stable since v0.1.5." \
  --layer canonical \
  --scope repo \
  --tags architecture,error-handling,validated

# Archive the team note
infynon loom note update team-error-pattern --status archived
```

## Example 6: Package Provenance Tracking

Track who introduced dependencies and why.

```bash
# When adding a new dependency
infynon loom note add pkg-serde-json \
  --title "serde_json added for config parsing" \
  --body "Required for JSON note serialization in Loom storage layer. Core dependency, unlikely to be removed." \
  --layer team \
  --scope package \
  --target serde_json \
  --author alien \
  --tags dependency,core

# When a risky dependency is flagged
infynon loom note add pkg-chrono-risk \
  --title "chrono has known RUSTSEC advisory" \
  --body "RUSTSEC-2020-0159: localtime_r unsoundness. We only use UTC functions which are safe. Tracked for replacement with time crate." \
  --layer team \
  --scope package \
  --target chrono \
  --tags dependency,risk,tracked

# Retrieve package notes
infynon loom retrieve --scope package --target chrono
```

## Example 7: Multi-Backend Sync Strategy

Use SQL for durable storage and Redis for live coordination.

```bash
# Setup
infynon loom source add-sql durable-db \
  --engine postgres \
  --url postgres://user:pass@db.internal:5432/loom \
  --user alien

infynon loom source add-redis live-cache \
  --url redis://redis.internal:6379/0 \
  --namespace loom \
  --user alien

# Set SQL as default (canonical + team notes persist here)
infynon loom source default durable-db

# Daily sync workflow
infynon loom sync --source durable-db --direction both
infynon loom sync --source live-cache --direction push

# Pull team notes from shared database before starting work
infynon loom sync --source durable-db --direction pull
```

## Example 8: TUI-Based Memory Browsing

```bash
# Open the TUI
infynon loom tui
```

In the TUI:
1. **Tab 1 (Overview)** — See Loom status, note counts per layer, backend health
2. **Tab 2 (Sources)** — Check which backends are configured and which is default
3. **Tab 3 (Notes)** — Browse all notes, filter by layer/scope, edit inline
4. **Tab 4 (Packages)** — See dependency provenance and risk attribution
5. **Tab 5 (EditLog)** — Review recent note changes

Use `Tab`/`Shift+Tab` to navigate fields, `Enter` to edit, `q` to quit.
