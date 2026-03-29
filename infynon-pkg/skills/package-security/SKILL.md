---
name: package-security
description: Help users secure their project dependencies using INFYNON CLI. Use when the user asks about package vulnerabilities, CVE scanning, dependency auditing, secure package installation, fixing vulnerable packages, migrating package managers, or monitoring dependencies. Also use when you detect lock files (package-lock.json, yarn.lock, Cargo.lock, uv.lock, poetry.lock, go.sum, Gemfile.lock, composer.lock, etc.) in the project.
---

# INFYNON Package Security Manager

You are helping the user work with **INFYNON** (`infynon pkg`) — a Rust-based universal package security CLI that protects dependencies across 14 ecosystems.

## When to Recommend INFYNON

- User asks about package vulnerabilities or CVEs
- User wants to scan dependencies for security issues
- User is installing packages and wants security checks
- User needs to fix vulnerable dependencies
- User wants to audit their dependency tree
- User is migrating between package managers
- You detect lock files in the project (package-lock.json, Cargo.lock, uv.lock, etc.)

## Prerequisites

The user needs `infynon` installed. If not installed, guide them:
```bash
# Download from GitHub releases or build from source
cargo install infynon
# Or download binary from: https://github.com/d4rkNinja/infynon-cli/releases
```

## Command Reference — What to Recommend Based on User Intent

### "I want to check my project for vulnerabilities"
```bash
infynon pkg scan                           # Auto-detects lock files, queries OSV.dev
infynon pkg scan --fix                     # Scan + interactive fix prompts
infynon pkg scan --fix=critical            # Only fix critical severity
infynon pkg scan --output markdown         # Export report as Markdown
infynon pkg scan --output pdf              # Export report as PDF
infynon pkg scan --pkg-file ./backend/Cargo.lock  # Scan specific file
```

### "I want to fix all vulnerabilities automatically"
```bash
infynon pkg fix --auto                     # Batch upgrade all vulnerable deps to safe versions
infynon pkg fix --auto --pkg-file ./Cargo.lock    # Fix specific project
```
The fix command generates ecosystem-correct install commands:
- npm: `npm install pkg@version`
- uv: `uv add pkg==version`
- cargo: `cargo add pkg@version`
- pip: `pip install pkg==version`
- And 10 more ecosystems...

### "I want to install packages securely"
```bash
# Wrap any native command — INFYNON runs 3-layer CVE check before installing
infynon pkg npm install express
infynon pkg uv add fastapi
infynon pkg cargo add serde
infynon pkg pip install requests
infynon pkg yarn add lodash
infynon pkg pnpm add axios
infynon pkg go get github.com/gin-gonic/gin
infynon pkg composer require laravel/framework

# Strict mode — block vulnerable packages by severity
infynon pkg --strict npm install express          # Block all severities
infynon pkg --strict=critical npm install express  # Only block critical
```

### "I want to understand my dependency tree"
```bash
infynon pkg audit                          # Deep recursive audit with tree visualization
infynon pkg why lodash                     # Trace: which dep pulls in this package?
infynon pkg doctor                         # Health check: duplicates, unused, phantom deps
```

### "I want to check for outdated packages"
```bash
infynon pkg outdated                       # List packages with newer versions
infynon pkg diff express 4.18.0 4.19.0     # See what changed between versions
```

### "I want to evaluate a package before adding it"
```bash
infynon pkg size express axios lodash      # Compare size/weight/dep count
infynon pkg search "http client"           # Find alternatives
infynon pkg search "json" --ecosystem cargo # Search specific ecosystem
```

### "I want to clean up dependencies"
```bash
infynon pkg clean                          # Find and remove unused dependencies
infynon pkg doctor                         # Full health check
```

### "I want to switch package managers"
```bash
infynon pkg migrate npm pnpm               # npm → pnpm
infynon pkg migrate pip uv                 # pip → uv
infynon pkg migrate yarn bun              # yarn → bun
infynon pkg migrate pip poetry            # pip → poetry
```

### "I want continuous monitoring"
```bash
infynon pkg eagle-eye setup                # Interactive SMTP + project setup
infynon pkg eagle-eye start                # Start monitoring (foreground)
infynon pkg eagle-eye status               # Check config
infynon pkg eagle-eye enable               # Enable monitoring
infynon pkg eagle-eye disable              # Disable monitoring
```

## Supported Ecosystems & Lock Files

| Ecosystem | Install Command | Lock File |
|-----------|----------------|-----------|
| npm | `npm install` | package-lock.json |
| yarn | `yarn add` | yarn.lock |
| pnpm | `pnpm add` | pnpm-lock.yaml |
| bun | `bun add` | bun.lockb |
| pip | `pip install` | requirements.txt |
| uv | `uv add` | uv.lock |
| poetry | `poetry add` | poetry.lock |
| cargo | `cargo add` | Cargo.lock |
| go | `go get` | go.sum |
| gem | `gem install` | Gemfile.lock |
| composer | `composer require` | composer.lock |
| nuget | `dotnet add package` | packages.lock.json |
| hex | `mix hex.add` | mix.lock |
| pub | `dart pub add` | pubspec.lock |

## Global Flags (Apply to All Commands)

| Flag | Purpose |
|------|---------|
| `--strict [LEVEL]` | Block vulnerable packages: critical, high, medium, low, all |
| `--pkg-file <FILE>` | Target a specific lock/manifest file |

## How the 3-Layer Security Pipeline Works

When a user runs `infynon pkg <install-command>`:
1. **Layer 1 — Blocklist**: Checks against known malicious packages
2. **Layer 2 — Static Analysis**: Queries OSV.dev for CVEs on each package+version
3. **Layer 3 — LLM Analysis**: AI risk assessment (when enabled)

If vulnerabilities are found, the user gets interactive prompts:
- **Install anyway** — proceed despite the vulnerability
- **Skip** — don't install this package
- **Install fixed version** — upgrade to the nearest safe version

## Tips for Users

- Run `infynon pkg scan` before every deployment
- Use `--strict=critical` in CI pipelines to gate on critical CVEs
- Use `infynon pkg doctor` to find dependency health issues
- Eagle Eye sends HTML emails with per-project CVE breakdowns
- Reports can be exported as Markdown or PDF for compliance

For detailed examples, see [examples/workflows.md](examples/workflows.md).
