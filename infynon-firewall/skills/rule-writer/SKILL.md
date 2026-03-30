---
name: rule-writer
description: Help users write custom WAF rules for INFYNON firewall. Use when the user wants to create custom rules, block specific patterns, allow specific IPs, flag suspicious requests, rate-limit specific routes, or tune the firewall beyond default settings. Also use when the user shows you traffic logs and asks what rules to write.
---

# INFYNON Custom Rule Writer

You are helping the user write **custom rules** for INFYNON's rule engine.

Custom rules run as the 4th stage of the pipeline: IP Filter → Rate Limiter → WAF → **Custom Rules**.
They are evaluated in priority order (lower number = higher priority). First matching rule wins.

---

## Rule Anatomy

```toml
[[rules]]
name = "rule-name"              # Unique identifier shown in TUI
priority = 1                    # Lower = higher priority; evaluated first
action = "Block"                # Block | Allow | Flag | RateLimit
conditions = [                  # ALL conditions must match (AND logic)
  { type = "PathPrefix", value = "/api" },
  { type = "Method", value = "POST" }
]
```

### Actions

| Action | Effect | Status Code |
|--------|--------|-------------|
| `Block` | Reject the request | 403 |
| `Allow` | Skip all remaining pipeline stages | — |
| `Flag` | Allow but log for review | — |
| `RateLimit` | Apply rate limiting | 429 when exceeded |

### All Condition Types

| Type | Matches On | Value Format |
|------|-----------|--------------|
| `IP` | Source IP or CIDR | `10.0.0.1` or `10.0.0.0/24` |
| `PathPrefix` | URL starts with | `/api/v2` |
| `PathExact` | URL equals | `/health` |
| `PathRegex` | URL matches regex | `^/v[0-9]+/users/.*` |
| `Method` | HTTP method | `POST` |
| `Header` | Header name:value | `X-Api-Key:mysecret` |
| `UserAgent` | User-Agent pattern (regex) | `.*bot.*` |
| `Body` | Request body pattern (regex) | `.*<script>.*` |
| `ContentType` | Content-Type header (regex) | `application/xml` |
| `RequestSize` | Body size in bytes | `> 1048576` |

---

## Recipe Book — Common Rules

### Allow health check bypassing all other rules

```toml
[[rules]]
name = "allow-healthcheck"
priority = 0
action = "Allow"
conditions = [
  { type = "PathExact", value = "/health" }
]
```

### Allow only internal IPs to access admin

```toml
[[rules]]
name = "admin-internal-only"
priority = 1
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/admin" },
  { type = "IP", value = "!10.0.0.0/8" }    # Negate: block if NOT internal
]
```

Or allowlist approach (allow internal, block everything else):
```toml
[[rules]]
name = "allow-internal-admin"
priority = 1
action = "Allow"
conditions = [
  { type = "PathPrefix", value = "/admin" },
  { type = "IP", value = "10.0.0.0/8" }
]

[[rules]]
name = "block-external-admin"
priority = 2
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/admin" }
]
```

### Block known security scanners

```toml
[[rules]]
name = "block-scanners"
priority = 1
action = "Block"
conditions = [
  { type = "UserAgent", pattern = ".*sqlmap.*|.*nikto.*|.*nmap.*|.*masscan.*|.*dirbuster.*|.*gobuster.*|.*wfuzz.*" }
]
```

### Block WordPress probing (even if you don't run WordPress)

```toml
[[rules]]
name = "block-wp-probes"
priority = 2
action = "Block"
conditions = [
  { type = "PathRegex", value = ".*wp-(admin|login|includes|content).*" }
]
```

### Rate-limit login endpoint specifically

```toml
[[rules]]
name = "rate-limit-login"
priority = 1
action = "RateLimit"
conditions = [
  { type = "PathExact", value = "/auth/login" },
  { type = "Method", value = "POST" }
]
```

Then set tight rate limits in `[rate_limit]`:
```toml
[rate_limit]
per_ip_per_second = 2
```

### Require API key on all API routes

```toml
[[rules]]
name = "require-api-key"
priority = 3
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/api" },
  { type = "Header", value = "!X-Api-Key:.*" }    # Block if header is absent
]
```

### Block large request bodies (prevent body-based DoS)

```toml
[[rules]]
name = "block-large-bodies"
priority = 2
action = "Block"
conditions = [
  { type = "RequestSize", value = "> 5242880" }    # 5MB
]
```

### Flag (log but allow) requests from suspicious user agents

```toml
[[rules]]
name = "flag-suspicious-ua"
priority = 5
action = "Flag"
conditions = [
  { type = "UserAgent", pattern = ".*python.*|.*curl.*|.*wget.*" }
]
```

### Block XML content-type on JSON-only APIs

```toml
[[rules]]
name = "block-xml-on-api"
priority = 4
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/api" },
  { type = "ContentType", pattern = "application/xml|text/xml" }
]
```

### Allow a specific IP to bypass rate limiting

```toml
[[rules]]
name = "allow-monitoring-ip"
priority = 0
action = "Allow"
conditions = [
  { type = "IP", value = "10.10.0.5" }    # Monitoring server
]
```

### Block path traversal attempts not caught by WAF

```toml
[[rules]]
name = "block-traversal"
priority = 2
action = "Block"
conditions = [
  { type = "PathRegex", value = ".*(\\.\\./|%2e%2e|%252e).*" }
]
```

---

## Multi-Condition Rules (AND Logic)

All conditions in a rule use AND logic — ALL must match. Use multiple rules for OR:

```toml
# Block POST requests to /api from unknown content-types
[[rules]]
name = "api-json-only"
priority = 3
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/api" },
  { type = "Method", value = "POST" },
  { type = "ContentType", pattern = "^(?!application/json).*" }
]

# Also block PUT with non-JSON
[[rules]]
name = "api-json-only-put"
priority = 3
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/api" },
  { type = "Method", value = "PUT" },
  { type = "ContentType", pattern = "^(?!application/json).*" }
]
```

---

## Apply Rules Without Restart

INFYNON hot-reloads config every 2 seconds. After editing `infynon.toml`:
1. Save the file
2. Wait 2 seconds
3. Rules are active — no restart needed

Or force a reload in TUI: press `r`.

---

## Verify Rules Are Working

```bash
# Check rules list with hit counts
infynon rules list

# In TUI: press 5 (Rules view) — shows custom rules + WAF status + hit counts

# Check logs for your new rule
infynon logs --verdict block --since 5m
```

---

## Priority Guide

Use these priority bands to keep rules organized:

| Priority | Use For |
|----------|---------|
| 0 | Absolute allows (health checks, monitoring IPs) |
| 1–5 | Emergency blocks (active attack response) |
| 10–20 | Security rules (scanner blocks, auth enforcement) |
| 50–100 | Traffic shaping (rate limits, content-type rules) |
| 200+ | Logging/flagging rules (Flag action) |
