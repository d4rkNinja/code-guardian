# Common Workflows

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
- name: CVE scan gate
  run: |
    infynon pkg scan --output markdown
    infynon pkg fix --auto
```

### CI Flag Reference

| Flag | Behavior | Exit Code | When to Use |
|------|----------|-----------|-------------|
| `--strict critical` | Fail if any critical CVE found | `1` | Hard gate — block release |
| `--strict high` | Fail if critical or high CVE found | `1` | Recommended CI default |
| `--auto-fix` | Silently upgrade to safe versions | `0` | Auto-remediation pipelines |
| `--skip-vulnerable` | Skip bad packages, install clean | `0` | Permissive CI |
| `--yes` | Install everything including vulnerable | `0` | Audit-only, never gate |

---

## New Project Setup

```bash
# 1. Initialize your project normally
npm init -y && npm install express mongoose dotenv

# 2. Secure it immediately
infynon pkg scan                    # Check for known CVEs
infynon pkg doctor                  # Check dependency health
infynon pkg eagle-eye setup         # Set up monitoring
```

---

## Secure Install — Drop-in Replacement

Replace your existing install commands with `infynon pkg` prefix:

```bash
# Before
npm install express lodash axios

# After — runs CVE check before installing
infynon pkg npm install express lodash axios

# Other ecosystems — same pattern
infynon pkg cargo add serde tokio
infynon pkg pip install fastapi uvicorn
infynon pkg uv add django
infynon pkg yarn add react react-dom
infynon pkg go get github.com/gin-gonic/gin
```

---

## Migration from pip to uv

```bash
# 1. Migrate
infynon pkg migrate pip uv

# 2. Verify the new lock file
infynon pkg scan --pkg-file uv.lock

# 3. Fix any issues
infynon pkg fix --auto
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

# What changed in this version update?
infynon pkg diff express 4.18.0 4.19.0

# How heavy is this package?
infynon pkg size axios node-fetch got

# Are there safer alternatives?
infynon pkg search "http client" --ecosystem npm
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

Eagle Eye scans all configured projects on a timer, sends HTML email alerts when new CVEs are found at or above your configured risk level.
