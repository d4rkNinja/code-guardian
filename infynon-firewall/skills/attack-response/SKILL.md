---
name: attack-response
description: Emergency playbook for responding to active attacks using INFYNON firewall. Use when the user is under attack, seeing suspicious traffic, experiencing DDoS, noticing brute-force attempts, or investigating blocked requests. Covers immediate IP blocking, log analysis, rule creation, and post-incident hardening.
---

# INFYNON Attack Response Playbook

You are helping the user respond to an **active security incident** using INFYNON firewall (`infynon`).

---

## Step 1 — Triage: Understand What's Happening

```bash
# See recent blocked requests (last hour)
infynon logs --verdict block --since 1h

# See live traffic stream
infynon logs --follow

# Check top attacking IPs
infynon monitor     # TUI view 6 (Stats) shows top IPs with block counts
```

**In TUI:**
- Press `3` — Blocked view (see what's being blocked and why)
- Press `4` — IP Inspector (search for specific IP, see per-IP stats)
- Press `6` — Stats (top blocked paths, top IPs, verdict breakdown)

---

## Step 2 — Immediate Containment

### Block a specific IP

```bash
infynon block 10.0.0.1
infynon block 192.168.1.100

# Verify it's blocked
infynon logs --ip 10.0.0.1 --since 5m
```

**In TUI:** Press `4` (IP Inspector), search for the IP, press `b` to block.

### Block a CIDR range (entire subnet)

Add to `infynon.toml` under `[ip_filter]`:
```toml
[ip_filter]
blocked_ips = ["10.0.0.0/24", "203.0.113.0/24"]
```
Config hot-reloads within 2 seconds — no restart needed.

### Enable maintenance mode (block ALL traffic immediately)

```bash
# In TUI: press m to toggle
# In config: set maintenance_mode = true in infynon.toml
```

Use maintenance mode when:
- You're under a heavy DDoS and need to stop all traffic instantly
- You need to patch a critical vulnerability right now
- Returns 503 to all requests until you toggle it off

---

## Step 3 — Identify the Attack Type

### Brute-force / Credential stuffing
**Signs:** Many POST requests to `/auth/login` from same or rotating IPs
```bash
infynon logs --verdict block --since 1h | grep "login"
```
**Response:**
```toml
[rate_limit]
per_ip_per_second = 2        # Tighten rate limit
per_path_per_second = 10     # Path-level limit

[[rules]]
name = "block-login-burst"
priority = 1
action = "RateLimit"
conditions = [
  { type = "PathExact", value = "/auth/login" },
  { type = "Method", value = "POST" }
]
```

### SQL injection scan
**Signs:** WAF blocking requests with SQLi patterns, high block rate from few IPs
```bash
infynon logs --verdict block --since 1h | grep "sqli\|SQLi\|sql"
```
**Response:** WAF handles this automatically. Check WAF is enabled:
```toml
[waf]
enabled = true    # Ensure this is true
```
Block the attacker's IP:
```bash
infynon block <attacker-ip>
```

### Path traversal / Scanner
**Signs:** Requests for `/.env`, `/wp-login`, `/.git`, `/phpMyAdmin`, etc.
```bash
infynon logs --verdict block --since 1h | grep "\.env\|wp-login\|\.git"
```
**Response:** These are blocked by default WAF. Add specific scanner signatures:
```toml
[[rules]]
name = "block-scanners"
priority = 1
action = "Block"
conditions = [
  { type = "UserAgent", pattern = ".*sqlmap.*|.*nikto.*|.*nmap.*|.*masscan.*" }
]
```

### DDoS / High-volume flood
**Signs:** Thousands of requests per second, server slowdown
**Response:**
```toml
[rate_limit]
requests_per_second = 50        # Lower global limit
per_ip_per_second = 5           # Aggressive per-IP limit
per_path_per_second = 20
```
Then set auto-ban to trigger fast:
```toml
[ip_filter]
auto_ban_threshold = 10         # Auto-block after 10 blocked requests (was 50)
```

### XSS injection attempts
**Signs:** WAF blocking requests with `<script>`, `javascript:`, `onerror=` patterns
WAF handles this automatically (12 XSS patterns compiled in).
If seeing a new XSS pattern:
```toml
[[rules]]
name = "custom-xss"
priority = 2
action = "Block"
conditions = [
  { type = "Body", pattern = ".*document\\.cookie.*" }
]
```

---

## Step 4 — Post-Incident Hardening

After the immediate incident is contained, harden the config:

### Tighten rate limits
```toml
[rate_limit]
requests_per_second = 100       # Global baseline
per_ip_per_second = 10          # Per-IP (lower for sensitive endpoints)
per_path_per_second = 50        # Per-path
```

### Add targeted custom rules for observed attack patterns
```toml
# Block specific IP ranges known for attacks
[ip_filter]
blocked_ips = ["185.220.101.0/24"]   # Known Tor exit nodes example

# Block common attack user agents
[[rules]]
name = "block-attack-uas"
priority = 1
action = "Block"
conditions = [
  { type = "UserAgent", pattern = ".*curl/.*|.*python-requests.*|.*Go-http.*" }
]

# Require JSON content-type for API routes (prevents form-encoded attacks)
[[rules]]
name = "api-json-only"
priority = 3
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/api" },
  { type = "Method", value = "POST" },
  { type = "ContentType", pattern = "^(?!application/json).*" }
]
```

### Set up email alerts for future incidents
```toml
[email]
enabled = true
smtp_host = "smtp.gmail.com"
smtp_port = 587
smtp_user = "you@gmail.com"
smtp_pass = "app-password"
from = "firewall@yourdomain.com"
to = ["admin@yourdomain.com"]
block_threshold = 50        # Alert after 50 blocks in a window
```

---

## Log Analysis Commands

```bash
# All blocks in the last hour
infynon logs --verdict block --since 1h

# All blocks from a specific IP
infynon logs --ip 10.0.0.1

# Filter to specific time windows
infynon logs --verdict block --since 30m
infynon logs --verdict block --since 24h

# Stream live (watch attack in real-time)
infynon logs --follow

# Check specific verdict types
infynon logs --verdict allow    # Normal traffic
infynon logs --verdict block    # Blocked requests
infynon logs --verdict ratelimited  # Rate-limited requests
```

Logs are written to `access.jsonl` and `blocked.jsonl` in the working directory. Parse with `jq`:
```bash
cat blocked.jsonl | jq '. | {ip: .source_ip, path: .path, reason: .reason, time: .timestamp}'
cat blocked.jsonl | jq -r '.source_ip' | sort | uniq -c | sort -rn | head -20
```

---

## After the Incident

1. **Review your block logs** for attack patterns you didn't anticipate
2. **Update custom rules** to catch similar attacks automatically next time
3. **Lower auto_ban_threshold** if the attacker was active for a long time before being blocked
4. **Consider adding email alerts** if you didn't have them — `block_threshold = 50` is a good start
5. **Run INFYNON package scan** — attackers who probe your API may also target your dependencies:
   ```bash
   infynon pkg scan
   ```
