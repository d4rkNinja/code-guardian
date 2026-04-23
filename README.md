# Code Guardian

Claude Code plugins for the **INFYNON** suite — package security, API flow testing, and shared coding memory.

## Plugins

### infynon-pkg — Package Security Manager
Universal secure package installation, CVE scanning, auto-fix, dependency auditing, and vulnerability monitoring across **14 ecosystems** (npm, yarn, pnpm, bun, pip, uv, poetry, cargo, go, gem, composer, nuget, hex, pub).

### infynon-weave — API Flow Testing
AI-driven node-based API flow testing with security probes, TUI visualization, assertion engine, context threading, and automated flow building.

### infynon-trace — Shared Coding Memory
Three-layer memory operating system for codebases:
- **Canonical memory** — architecture decisions, API contracts, security constraints (highest trust, promoted only)
- **Team memory** — handoffs, PR notes, caveats, branch context (medium trust, agent-writable)
- **User memory** — personal observations, task context, experiments (low trust, promotable)

With session hooks (auto-load on start, capture on end), Redis and SQL backends, TUI inspection, and promotion workflows.

---

## Installation

### Step 1: Install INFYNON CLI

> **INFYNON CLI**: [github.com/d4rkNinja/infynon-cli](https://github.com/d4rkNinja/infynon-cli)

**Check if already installed:**
```bash
infynon --version
```

#### npm (Recommended — all platforms, no Rust required)

```bash
npm install -g infynon
```

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.sh | bash
```

#### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.ps1 | iex
```

#### Build from Source (requires Rust)

```bash
cargo install --git https://github.com/d4rkNinja/infynon-cli
```

Pre-built binaries also available on the [Releases page](https://github.com/d4rkNinja/infynon-cli/releases) for Windows x64, Linux x64/ARM64 (musl), macOS x64/ARM64.

**Verify:**
```bash
infynon --version
infynon pkg --help
infynon trace --help
```

### Step 2: Install Claude Code Plugins

```bash
# Add the marketplace
/plugin marketplace add d4rkNinja/code-guardian

# Install plugins
/plugin install infynon-pkg@d4rkNinja
/plugin install infynon-weave@d4rkNinja
/plugin install infynon-trace@d4rkNinja

# Activate
/reload-plugins
```

Or load locally for development:
```bash
claude --plugin-dir ./infynon-pkg --plugin-dir ./infynon-weave --plugin-dir ./infynon-trace
```

---

## How These Plugins Work

These are **contextual skills** — once installed, Claude Code automatically knows how to help users with INFYNON. Claude will:

- Check if INFYNON is installed and guide through installation if not found
- Recommend the right `infynon` commands based on what the user is trying to do
- Detect lock files and suggest security scans
- Help manage coding memory across canonical, team, and user layers
- Run session hooks to load/save memory automatically
- Guide users through TUI keyboard shortcuts
- Explain vulnerability scan results and fix options
- Recommend CI-friendly flags (`--strict`, `--no-input`, `--auto-fix`, `--skip-vulnerable`, `--json`)

### Skills

| Plugin | Skill | Auto-triggers When |
|--------|-------|--------------------|
| infynon-pkg | `package-security` | User asks about package vulnerabilities, CVE scanning, dependency auditing, or Claude detects lock files in the project |
| infynon-pkg | `cve-triage` | User needs help interpreting CVE scan results or prioritizing fixes |
| infynon-pkg | `eagle-eye-monitor` | User wants continuous vulnerability monitoring with email alerts |
| infynon-weave | `weave` | User asks about API testing, flow building, security probes, or Claude detects `.infynon/api/` in the project |
| infynon-trace | `memory-ops` | User asks about coding memory, notes, handoffs, or Claude detects `.infynon/trace/` in the project |
| infynon-trace | `canonical-memory` | User asks about architecture decisions, truth memory, or validated knowledge |
| infynon-trace | `session-hooks` | Session starts or ends, user asks about memory hooks |

### Agents

| Plugin | Agent | Purpose |
|--------|-------|---------|
| infynon-pkg | `pkg-guardian` | Deep package security analysis, CVE triage, migration guidance, CI setup |
| infynon-weave | `weaver` | API flow design, node wiring, security probe interpretation, CI pipelines |
| infynon-trace | `trace-guardian` | Memory layer management, promotion workflows, session hooks, backend setup |

### Hooks (Opt-In)

Trace hooks are installed **per-project** in `.claude/settings.json` when the user explicitly asks. They are never auto-installed or placed in system-level settings.

| Hook | Trigger | Behavior |
|------|---------|----------|
| `SessionStart` | New conversation begins | Load canonical memory (always), ask about team memory, optionally load user memory, pull from remote |
| `Stop` | Claude finishes responding | Remind to save observations, compact stale notes, push to remote. Never auto-writes canonical. |

**Install hooks:**
```bash
# Run the install script in your project directory
bash <path-to-code-guardian>/infynon-trace/hooks/install.sh .

# Or ask Claude: "Set up trace hooks for this project"
```

Hooks are written to `<your-project>/.claude/settings.json` — not `~/.claude/settings.json`.

---

## Package Security Manager — Quick Reference

```bash
# Scan for vulnerabilities
infynon pkg scan
infynon pkg scan --json

# Explain one package and its remediation path
infynon pkg explain serde_json

# Install packages securely (wraps any package manager)
infynon pkg npm install express
infynon pkg uv add fastapi
infynon pkg cargo add serde

# CI / non-interactive flags (no prompts)
infynon pkg npm install express --strict high      # fail build on critical/high (exit 3)
infynon pkg npm install express --json --strict high # machine-readable install contract
infynon pkg npm install express --auto-fix         # auto-upgrade to safe versions
infynon pkg npm install express --skip-vulnerable  # skip bad packages silently
infynon pkg npm install express --yes              # install everything (audit-only CI)

# Auto-fix all vulnerabilities
infynon pkg fix --auto

# Deep audit
infynon pkg audit

# Why is this package in my tree?
infynon pkg why lodash

# Health check
infynon pkg doctor

# Check for updates
infynon pkg outdated

# Compare versions
infynon pkg diff express 4.18.0 4.19.0

# Package size analysis
infynon pkg size express axios

# Remove unused deps
infynon pkg clean

# Migrate package managers
infynon pkg migrate pip uv

# Continuous monitoring
infynon pkg eagle-eye setup
infynon pkg eagle-eye start
```

### CI / Agent Flag Reference

| Flag | Behavior | Exit Code |
|------|----------|-----------|
| `--json` | Machine-readable JSON to stdout for scan/install automation | scan `0/1/2`, install `0/2/3/4` |
| `--strict [LEVEL]` | Block if vulnerabilities at/above level are found during install | `3` on block |
| `--no-input` | Disable prompts and fail if a decision would be required | `4` on install |
| `--auto-fix` | Upgrade to safe versions silently; skip if no fix | `0` |
| `--skip-vulnerable` | Skip vulnerable packages, install clean ones | `0` |
| `--yes` | Install all packages including vulnerable ones | `0` |

**Compatibility note:** `--agent` still works as a deprecated alias for `--json`, but new docs and new scripts should use `--json`.

### Supported Ecosystems

npm, yarn, pnpm, bun, pip, uv, poetry, cargo, go, gem, composer, nuget, hex, pub

---

## Trace — Shared Coding Memory

### Three-Layer Memory Model

```
┌─────────────────────────────────────────────┐
│  Canonical Memory (Highest Trust)           │
│  Architecture, API contracts, constraints   │
│  Promoted only. Never auto-written.         │
├─────────────────────────────────────────────┤
│  Team Memory (Medium Trust)                 │
│  Handoffs, caveats, PR notes, branch ctx    │
│  Agent-writable. Compacted often.           │
├─────────────────────────────────────────────┤
│  User Memory (Low Trust)                    │
│  Personal notes, observations, experiments  │
│  Promotable to team. Never affects canon.   │
└─────────────────────────────────────────────┘
```

### Quick Reference

```bash
# Initialize Trace with the default local SQLite backend
infynon trace init

# Add an optional shared backend
infynon trace source add-sql team-db \
  --engine sqlite \
  --url sqlite://.infynon/trace/trace.db \
  --user alien --default

# Create notes
infynon trace note add arch-decision \
  --title "Auth uses middleware" \
  --body "All auth flows go through middleware" \
  --layer canonical --scope repo

infynon trace note add handoff-payment \
  --title "Payment webhook incomplete" \
  --body "Stripe webhook handler needs idempotency testing" \
  --layer team --scope branch --target feature/payment

# Retrieve memory
infynon trace retrieve --layer canonical
infynon trace retrieve --layer team --scope branch --target feature/payment
infynon trace retrieve --tag handoff
infynon trace retrieve --scope package --target chrono --format markdown

# Sync
infynon trace sync --direction both

# Compact stale notes
infynon trace compact

# TUI
infynon trace tui
```

### Session Hooks

**Session start:**
1. Load canonical memory (always)
2. Ask: "Load team memory?" → yes/no
3. Optionally load user memory
4. Pull from remote

**Session end:**
1. Ask: "Any observations to save?"
2. Mark stale notes
3. Flag promotion candidates
4. Compact and sync
5. Never auto-write canonical

### Note Scopes

| Scope | Example |
|-------|---------|
| `repo` | Repository-wide architectural facts |
| `branch` | Branch-specific handoff context |
| `pr` | PR-linked notes for reviewers |
| `file` | File-specific caveats and warnings |
| `user` | User-scoped personal notes |
| `session` | Temporary session context (auto-compacted) |
| `package` | Dependency provenance and risk tracking |

### Promotion Path

```
User Memory → Team Memory → Canonical Memory
     │              │              │
  Low trust    Medium trust    High trust
  Personal     Shared          Validated
  Auto-write   Agent-write     Promote only
```

Promotion requires: merge + validation + review + repeated reuse without contradiction.

---

## Troubleshooting

### INFYNON CLI Not Found
```bash
# Check installation
infynon --version

# Install via npm (recommended)
npm install -g infynon

# Or via script
curl -fsSL https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.sh | bash

# Windows
irm https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.ps1 | iex

# Verify
infynon --version
```

### Plugin Not Loading
```bash
/plugin                    # Check Errors tab
/reload-plugins            # Reload all plugins
```

### Skills Not Appearing
```bash
rm -rf ~/.claude/plugins/cache     # Clear cache
# Restart Claude Code, reinstall
```

---

## Plugin References

- [Claude Code Plugins](https://code.claude.com/docs/en/plugins)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Discover Plugins](https://code.claude.com/docs/en/discover-plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)

---

## Project Structure

```
code-guardian/
├── .claude-plugin/
│   └── marketplace.json              # Marketplace catalog
├── infynon-pkg/                      # Package Security Manager plugin
│   ├── .claude-plugin/plugin.json
│   ├── agents/pkg-guardian.md        # Package security agent
│   └── skills/
│       ├── package-security/         # Core package security skill
│       ├── cve-triage/               # CVE interpretation and prioritization
│       └── eagle-eye-monitor/        # Continuous vulnerability monitoring
├── infynon-weave/                    # API Flow Testing plugin
│   ├── .claude-plugin/plugin.json
│   ├── agents/api-weaver.md          # API testing agent
│   └── skills/
│       └── weave/                    # Flow building, probes, TUI
├── infynon-trace/                     # Shared Coding Memory plugin
│   ├── .claude-plugin/plugin.json
│   ├── agents/trace-guardian.md       # Memory layer management agent
│   ├── hooks/
│   │   ├── session-start.md          # Load canonical + ask team memory
│   │   ├── session-end.md            # Capture observations, compact, sync
│   │   ├── settings-template.json    # Hook config template for .claude/settings.json
│   │   └── install.sh                # Script to install hooks into a project
│   └── skills/
│       ├── memory-ops/               # Core memory operations
│       │   └── examples/workflows.md
│       ├── canonical-memory/         # Canonical layer management
│       └── session-hooks/            # Session start/end workflows
└── README.md
```

---

## License

MIT License

---

**Code Guardian** by [d4rkNinja](https://github.com/d4rkNinja) — Powered by [INFYNON](https://github.com/d4rkNinja/infynon-cli)

