# Code Guardian

Claude Code plugins for the **INFYNON** security suite — a Rust-based dual-mode security tool for package dependency protection and network firewall management.

## Plugins

### 🛡️ infynon-pkg — Package Security Manager
Universal secure package installation, CVE scanning, auto-fix, dependency auditing, and vulnerability monitoring across **14 ecosystems** (npm, yarn, pnpm, bun, pip, uv, poetry, cargo, go, gem, composer, nuget, hex, pub).

### 🔥 infynon-firewall — Network Firewall
Real-time reverse proxy WAF with TUI dashboard, multi-stage request pipeline (IP filter → rate limiter → WAF → custom rules), multi-upstream routing, hot config reload, maintenance mode, and email alerts.

---

## Installation

### Step 1: Install INFYNON CLI

> **INFYNON CLI**: [github.com/d4rkNinja/infynon-cli](https://github.com/d4rkNinja/infynon-cli)

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.sh | bash
```

#### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/d4rkNinja/infynon-cli/main/scripts/install.ps1 | iex
```

#### Using Cargo

```bash
cargo install --git https://github.com/d4rkNinja/infynon-cli
```

Pre-built binaries also available on the [Releases page](https://github.com/d4rkNinja/infynon-cli/releases) for Windows x64, Linux x64/ARM64 (musl), macOS x64/ARM64.

### Step 2: Install Claude Code Plugins

```bash
# Add the marketplace
/plugin marketplace add d4rkNinja/code-guardian

# Install plugins
/plugin install infynon-pkg@d4rkNinja
/plugin install infynon-firewall@d4rkNinja

# Activate
/reload-plugins
```

Or load locally for development:
```bash
claude --plugin-dir ./infynon-pkg --plugin-dir ./infynon-firewall
```

---

## How These Plugins Work

These are **contextual skills** — once installed, Claude Code automatically knows how to help users with INFYNON. Claude will:

- Recommend the right `infynon` commands based on what the user is trying to do
- Detect lock files and suggest security scans
- Help write firewall configurations (`infynon.toml`)
- Guide users through TUI keyboard shortcuts
- Explain vulnerability scan results and fix options

### Skills

| Plugin | Skill | Auto-triggers When |
|--------|-------|--------------------|
| infynon-pkg | `package-security` | User asks about package vulnerabilities, CVE scanning, dependency auditing, or Claude detects lock files in the project |
| infynon-firewall | `firewall-setup` | User asks about firewall config, WAF rules, rate limiting, IP blocking, traffic monitoring, or Claude detects `infynon.toml` |

### Agents

| Plugin | Agent | Purpose |
|--------|-------|---------|
| infynon-pkg | `pkg-guardian` | Deep package security analysis, CVE triage, migration guidance |
| infynon-firewall | `fw-guardian` | Firewall setup, rule authoring, attack investigation, config tuning |

---

## Package Security Manager — Quick Reference

```bash
# Scan for vulnerabilities
infynon pkg scan

# Scan + auto-fix
infynon pkg scan --fix

# Install packages securely (wraps any package manager)
infynon pkg npm install express
infynon pkg uv add fastapi
infynon pkg cargo add serde

# Block critical CVEs
infynon pkg --strict=critical npm install lodash

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

### Supported Ecosystems

npm, yarn, pnpm, bun, pip, uv, poetry, cargo, go, gem, composer, nuget, hex, pub

---

## Network Firewall — Quick Reference

```bash
# Initialize config
infynon init --port 8080 --upstream 127.0.0.1 --upstream-port 3000

# Start firewall + TUI
infynon start

# Start without TUI (servers)
infynon start --headless

# Monitor traffic
infynon monitor

# Block/unblock IPs
infynon block 10.0.0.1
infynon unblock 10.0.0.1

# Manage rules
infynon rules list
infynon rules enable <name>

# View logs
infynon logs --verdict block --since 1h

# Validate config
infynon config check
```

### Architecture

```
Internet → INFYNON :8080 → [IP Filter → Rate Limiter → WAF → Custom Rules] → Backend :3000
                ↕
          TUI Dashboard (7 views)
```

### TUI Shortcuts

| Key | Action |
|-----|--------|
| 1-7 | Dashboard, Feed, Blocked, IPs, Rules, Stats, Config |
| q | Quit |
| / | Search |
| ? | Help |
| m | Maintenance mode |
| r | Reload config |
| b/u | Block/unblock IP |
| s | Save config |

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
│   └── marketplace.json            # Marketplace catalog
├── infynon-pkg/                    # Package Security Manager plugin
│   ├── .claude-plugin/plugin.json
│   ├── agents/pkg-guardian.md      # Package security agent
│   └── skills/package-security/    # Contextual skill
│       ├── SKILL.md                # Full command reference + guidance
│       └── examples/workflows.md   # CI/CD, migration, audit workflows
├── infynon-firewall/               # Network Firewall plugin
│   ├── .claude-plugin/plugin.json
│   ├── agents/fw-guardian.md       # Firewall agent
│   └── skills/firewall-setup/      # Contextual skill
│       ├── SKILL.md                # Config guide + command reference
│       └── examples/scenarios.md   # Protection, multi-upstream, attack investigation
└── README.md
```

## Troubleshooting

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

### INFYNON CLI Not Found
```bash
infynon --version          # Verify installation
# If missing: cargo install infynon
```

---

## License

MIT License

---

**Code Guardian** by [d4rkNinja](https://github.com/d4rkNinja) — Powered by [INFYNON](https://github.com/d4rkNinja/infynon-cli)
