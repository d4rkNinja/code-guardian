# Common Scenarios

## Protect an Express.js Backend

```bash
# Backend runs on port 3000
infynon init --port 80 --upstream 127.0.0.1 --upstream-port 3000
infynon start
# Now point DNS to the server — traffic goes through INFYNON on port 80
```

## Protect Multiple Microservices

```toml
# infynon.toml
port = 443
upstream = "127.0.0.1:3000"  # Default backend

[[upstreams]]
path_prefix = "/api/users"
target = "127.0.0.1:4001"
strip_prefix = false

[[upstreams]]
path_prefix = "/api/orders"
target = "127.0.0.1:4002"
strip_prefix = false

[[upstreams]]
path_prefix = "/static"
target = "127.0.0.1:8080"
strip_prefix = true
```

## Block Common Attack Patterns

```toml
# Block vulnerability scanners
[[rules]]
name = "block-vuln-scanners"
priority = 1
action = "Block"
conditions = [
  { type = "UserAgent", pattern = ".*(sqlmap|nikto|nmap|masscan|ZmEu|dirbuster).*" }
]

# Block WordPress probes on non-WP sites
[[rules]]
name = "block-wp-probes"
priority = 2
action = "Block"
conditions = [
  { type = "PathPrefix", value = "/wp-" }
]

# Rate limit login endpoint
[[rules]]
name = "rate-limit-login"
priority = 3
action = "RateLimit"
conditions = [
  { type = "PathExact", value = "/api/auth/login" },
  { type = "Method", value = "POST" }
]
```

## Production Headless Deployment

```bash
# Run without TUI
infynon start --headless --config /etc/infynon/infynon.toml

# Monitor via logs
infynon logs --follow --verdict block

# Or connect TUI separately
infynon monitor --config /etc/infynon/infynon.toml
```

## Investigating an Attack

```bash
# 1. Check recent blocks
infynon logs --verdict block --since 1h --count 100

# 2. Inspect suspicious IP
# (In TUI, press 4 for IP Inspector, search the IP)

# 3. Block the attacker
infynon block 203.0.113.50

# 4. Check stats
infynon status
```
