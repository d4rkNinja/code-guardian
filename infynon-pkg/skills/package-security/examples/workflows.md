# Common Workflows

## CI/CD Pipeline Integration

### GitHub Actions — Block on Critical CVEs
```yaml
- name: Security scan
  run: |
    infynon pkg scan --fix=critical
    if [ $? -ne 0 ]; then
      echo "Critical vulnerabilities found!"
      exit 1
    fi
```

### Pre-deploy Check
```bash
infynon pkg scan --output markdown && infynon pkg fix --auto
```

## New Project Setup

```bash
# 1. Initialize your project normally
npm init -y && npm install express mongoose dotenv

# 2. Secure it
infynon pkg scan                    # Check for known CVEs
infynon pkg doctor                  # Check dependency health
infynon pkg eagle-eye setup         # Set up monitoring
```

## Migration from pip to uv

```bash
# 1. Migrate
infynon pkg migrate pip uv

# 2. Verify
infynon pkg scan --pkg-file uv.lock

# 3. Fix any issues
infynon pkg fix --auto
```

## Full Security Audit

```bash
# 1. Scan for CVEs
infynon pkg scan --output both

# 2. Audit dependency tree
infynon pkg audit

# 3. Check health
infynon pkg doctor

# 4. Check for outdated packages
infynon pkg outdated

# 5. Auto-fix what's possible
infynon pkg fix --auto

# 6. Clean unused deps
infynon pkg clean
```
