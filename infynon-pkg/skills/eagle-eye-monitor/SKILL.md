---
name: eagle-eye-monitor
description: Help users set up and manage INFYNON Eagle Eye — continuous CVE monitoring with scheduled email alerts. Use when the user wants to monitor projects for new vulnerabilities over time, set up automated CVE alerts, configure SMTP for email notifications, or manage ongoing security monitoring.
---

# INFYNON Eagle Eye — Continuous CVE Monitoring

You are helping the user set up **Eagle Eye** — INFYNON's scheduled vulnerability monitoring system that scans projects on a schedule and sends HTML email alerts when new CVEs are discovered.

---

## What Eagle Eye Does

- Scans one or more project directories on a configurable schedule
- Queries OSV.dev for new CVEs since the last scan
- Sends HTML email alerts with per-project CVE breakdowns
- Runs as a foreground process (suitable for a server or always-on machine)

---

## Setup — Interactive Wizard

```bash
infynon pkg eagle-eye setup
```

The wizard prompts for:
1. **SMTP host** (e.g., `smtp.gmail.com`, `email-smtp.us-east-1.amazonaws.com`)
2. **SMTP port** (587 for STARTTLS, 465 for SSL)
3. **SMTP username / password** (or AWS SES credentials)
4. **From address** (e.g., `security@yourcompany.com`)
5. **Alert recipients** (comma-separated email list)
6. **Project paths to monitor** (absolute paths to directories with lock files)
7. **Risk level threshold** (LOW / MEDIUM / HIGH / CRITICAL — only alert on this severity and above)
8. **Scan interval** (hourly, daily, weekly)

Config is stored at `~/.infynon/eagle-eye.toml`.

---

## Start Monitoring

```bash
infynon pkg eagle-eye start           # Start in foreground (blocks the terminal)
infynon pkg eagle-eye status          # Check config and last scan time
infynon pkg eagle-eye enable          # Enable (if previously disabled)
infynon pkg eagle-eye disable         # Pause monitoring without deleting config
```

---

## SMTP Configuration Examples

### Gmail (app password required)
```
smtp_host: smtp.gmail.com
smtp_port: 587
smtp_user: you@gmail.com
smtp_pass: your-app-password   # Generate at myaccount.google.com → Security → App passwords
```

### AWS SES
```
smtp_host: email-smtp.us-east-1.amazonaws.com
smtp_port: 587
smtp_user: <SMTP username from SES console>
smtp_pass: <SMTP password from SES console>
```

### Self-hosted (Postfix / Mailcow)
```
smtp_host: mail.yourdomain.com
smtp_port: 587
smtp_user: alerts@yourdomain.com
smtp_pass: your-password
```

---

## What the Alert Email Contains

Each alert email includes:
- **Summary**: total new CVEs found across all projects, breakdown by severity
- **Per-project section**: project name, affected packages, CVE IDs, severity, safe version, fix command
- **Direct fix commands**: copy-paste-ready `infynon pkg fix` commands

---

## Run in the Background (Linux / macOS)

Eagle Eye runs in the foreground. To keep it running:

```bash
# systemd service
cat > /etc/systemd/system/eagle-eye.service << 'EOF'
[Unit]
Description=INFYNON Eagle Eye CVE Monitor
After=network.target

[Service]
ExecStart=/usr/local/bin/infynon pkg eagle-eye start
Restart=always
User=youruser

[Install]
WantedBy=multi-user.target
EOF

systemctl enable eagle-eye
systemctl start eagle-eye
```

```bash
# Or with screen
screen -dmS eagle-eye infynon pkg eagle-eye start
```

```bash
# Or with nohup
nohup infynon pkg eagle-eye start > ~/eagle-eye.log 2>&1 &
```

---

## Monitoring Multiple Projects

During setup, provide multiple project paths:
```
Project paths: /home/user/api-backend, /home/user/frontend, /home/user/mobile-app
```

Eagle Eye scans each path for all supported lock files (package-lock.json, Cargo.lock, uv.lock, etc.) and reports per-project.

---

## Risk Level Configuration

| Level | Sends alert for |
|-------|----------------|
| `LOW` | All CVEs including informational |
| `MEDIUM` | Medium + High + Critical |
| `HIGH` | High + Critical only (recommended for most teams) |
| `CRITICAL` | Critical CVEs only (minimal noise) |

**Recommended:** `HIGH` — alerts you to serious vulnerabilities without flooding your inbox with low-severity noise.

---

## Combine with CI Gates

Eagle Eye catches new CVEs between releases. Pair it with CI gates for defense-in-depth:

```yaml
# On every commit: hard block
- run: infynon pkg npm install --strict high

# Nightly: full scan with report
- run: infynon pkg scan --output markdown
```

Eagle Eye handles the ongoing monitoring; CI gates handle the moment of install.
