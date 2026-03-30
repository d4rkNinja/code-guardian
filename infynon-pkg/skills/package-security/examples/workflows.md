# Common Workflows

> **All install commands go through `infynon pkg` with a CI-mode flag. Never run raw install commands directly.**
> Raw commands (`npm install`, `pip install`, `cargo add`, etc.) prompt for user input when vulnerabilities are found — AI agents and CI pipelines cannot handle that. Always add `--strict high`, `--auto-fix`, `--skip-vulnerable`, or `--yes`.

---

## CI/CD Pipeline Integration

### GitHub Actions — Block on Critical/High CVEs
```yaml
- name: Secure install (fail on critical/high)
  run: infynon pkg npm install --strict high
```

### GitHub Actions — Auto-fix Vulnerable Packages
```yaml
- name: Secure install (auto-upgrade to safe versions)
  run: infynon pkg npm install --auto-fix
```

### GitHub Actions — Skip Vulnerable, Install Safe Only
```yaml
- name: Secure install (skip vulnerable packages)
  run: infynon pkg npm install --skip-vulnerable
```

### GitHub Actions — Full Audit Gate
```yaml
- name: CVE scan + auto-fix gate
  run: |
    infynon pkg scan --output markdown
    infynon pkg fix --auto
```

### GitHub Actions — Multi-Ecosystem Projects
```yaml
- name: Secure Node.js dependencies
  run: infynon pkg npm install --strict high

- name: Secure Python dependencies
  run: infynon pkg pip install fastapi uvicorn --strict high

- name: Secure Rust dependencies
  run: infynon pkg cargo add serde tokio --strict high
```

### CI Flag Reference

| Flag | Behavior | Exit Code | When to Use |
|------|----------|-----------|-------------|
| `--strict critical` | Fail if any critical CVE found | `1` | Hard gate — block release |
| `--strict high` | Fail if critical or high CVE found | `1` | Recommended CI default |
| `--strict medium` | Fail if critical, high, or medium | `1` | Strict compliance pipelines |
| `--strict low` | Fail on all except informational | `1` | Zero-tolerance policy |
| `--strict` / `--strict all` | Fail on any vulnerability | `1` | Maximum security |
| `--auto-fix` | Silently upgrade to safe versions | `0` | Auto-remediation pipelines |
| `--skip-vulnerable` | Skip bad packages, install clean | `0` | Permissive CI |
| `--yes` | Install everything including vulnerable | `0` | Audit-only, never gate |

---

## New Project Setup

```bash
# 1. Initialize your project
npm init -y

# 2. Install dependencies securely through infynon — NOT raw npm install
infynon pkg npm install express mongoose dotenv --strict high

# 3. Scan the full lock file after setup
infynon pkg scan

# 4. Check dependency health
infynon pkg doctor

# 5. Set up continuous monitoring
infynon pkg eagle-eye setup
```

For Python:
```bash
# Initialize
uv init my-project && cd my-project

# Install securely — NOT raw uv add / pip install
infynon pkg uv add fastapi sqlalchemy alembic --strict high

# Scan and audit
infynon pkg scan
infynon pkg doctor
```

For Rust:
```bash
# Initialize
cargo init my-project && cd my-project

# Add dependencies securely — NOT raw cargo add
infynon pkg cargo add serde tokio reqwest --strict high

# Scan and audit
infynon pkg scan
infynon pkg doctor
```

---

## Secure Install — Drop-in Replacement

Replace every raw install command with the `infynon pkg` prefix + a CI flag:

```bash
# WRONG — raw commands run without security checks and may prompt for input
npm install express lodash axios
pip install fastapi uvicorn
cargo add serde tokio
yarn add react react-dom
pnpm add vite
bun add hono
go get github.com/gin-gonic/gin
gem install rails
composer require laravel/framework
uv add django

# CORRECT — same installs, routed through INFYNON security pipeline
infynon pkg npm install express lodash axios --strict high
infynon pkg pip install fastapi uvicorn --strict high
infynon pkg cargo add serde tokio --strict high
infynon pkg yarn add react react-dom --strict high
infynon pkg pnpm add vite --strict high
infynon pkg bun add hono --strict high
infynon pkg go get github.com/gin-gonic/gin --strict high
infynon pkg gem install rails --strict high
infynon pkg composer require laravel/framework --strict high
infynon pkg uv add django --strict high
```

Auto-fix variant (silently upgrades vulnerable packages):
```bash
infynon pkg npm install express lodash axios --auto-fix
infynon pkg pip install fastapi uvicorn --auto-fix
infynon pkg cargo add serde tokio --auto-fix
infynon pkg yarn add react react-dom --auto-fix
infynon pkg uv add django --auto-fix
```

---

## Installing Specific Versions

```bash
# npm
infynon pkg npm install "express@4.18.2" --strict high
infynon pkg npm install "lodash@4.17.21" --auto-fix

# pip
infynon pkg pip install "requests==2.31.0" --strict high
infynon pkg pip install "django==4.2.7" --auto-fix

# cargo
infynon pkg cargo add "serde@1.0.196" --strict high
infynon pkg cargo add "tokio@1.35.0" --auto-fix

# yarn
infynon pkg yarn add "express@4.18.2" --strict high

# uv
infynon pkg uv add "fastapi==0.104.0" --strict high

# go
infynon pkg go get "github.com/gin-gonic/gin@v1.9.1" --strict high

# gem
infynon pkg gem install "rails:7.1.0" --strict high

# composer
infynon pkg composer require "laravel/framework:^10.0" --strict high
```

---

## Migration from pip to uv

```bash
# 1. Migrate (no install commands needed — infynon handles it)
infynon pkg migrate pip uv

# 2. Verify the new lock file
infynon pkg scan --pkg-file uv.lock

# 3. Fix any issues found
infynon pkg fix --auto
```

Other migrations:
```bash
infynon pkg migrate npm pnpm      # npm → pnpm
infynon pkg migrate yarn bun      # yarn → bun
infynon pkg migrate pip poetry    # pip → poetry
```

---

## Full Security Audit Workflow

```bash
# 1. Scan for CVEs — export report
infynon pkg scan --output both

# 2. Audit full dependency tree
infynon pkg audit

# 3. Check dependency health
infynon pkg doctor

# 4. Check for outdated packages
infynon pkg outdated

# 5. Auto-fix what's possible
infynon pkg fix --auto

# 6. Clean unused deps
infynon pkg clean
```

---

## Investigate a Specific Package

```bash
# Why is this package even in my tree?
infynon pkg why lodash
infynon pkg why lodash --pkg-file package-lock.json

# What changed in this version update?
infynon pkg diff express 4.18.0 4.19.0
infynon pkg diff serde 1.0.150 1.0.196 --ecosystem cargo
infynon pkg diff requests 2.28.0 2.31.0 --ecosystem pypi

# How heavy is this package?
infynon pkg size axios node-fetch got
infynon pkg size serde tokio reqwest --ecosystem cargo

# Are there safer alternatives?
infynon pkg search "http client" --ecosystem npm
infynon pkg search "json" --ecosystem cargo
```

---

## Choosing the Right CI Flag

```
Need to block vulnerable packages from entering the build?
→ --strict high  (or --strict critical for a looser gate)

Want the build to always succeed but still fix vulnerabilities?
→ --auto-fix

Want the build to always succeed and skip unfixable packages?
→ --skip-vulnerable

Running a pure audit — just want to log results, never block?
→ --yes  (then run infynon pkg scan separately to check)
```

Example: lock file scan gate in CI (separate from install):
```bash
# Step 1: Install all deps (audit-only mode)
infynon pkg npm install --yes

# Step 2: Fail the build if critical CVEs exist in lock file
infynon pkg scan
# or target a specific level:
# infynon pkg scan --fix critical
```

---

## Eagle Eye — Continuous Monitoring

```bash
# 1. Set up (interactive — SMTP, project paths, risk level, schedule)
infynon pkg eagle-eye setup

# 2. Start monitoring in foreground
infynon pkg eagle-eye start

# 3. Check status
infynon pkg eagle-eye status

# Enable/disable without losing config
infynon pkg eagle-eye enable
infynon pkg eagle-eye disable
```

Eagle Eye scans all configured projects on a timer, sends HTML email alerts when new CVEs are found at or above your configured risk level. Runs fully non-interactive after initial setup.
