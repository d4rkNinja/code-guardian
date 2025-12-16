# Security Workspace Plugin (sec)

**Advanced security vulnerability scanner and remediation advisor for Claude Code**

## Overview

The **sec** plugin provides comprehensive security analysis for your codebase through **Sentinel**, an elite security agent that performs multi-layer vulnerability scanning, dependency analysis, and provides intelligent remediation strategies.

## Features

- 🔍 **Multi-Layer Security Analysis**: Code-level + dependency scanning
- 🌐 **Native Tool Integration**: Runs `npm audit`, `pip-audit`, `cargo audit`, etc. FIRST
- 🎯 **Context-Aware Risk Assessment**: Detects if vulnerable code is actually used
- 💡 **Actionable Remediation**: Specific version upgrades and code fixes
- 📊 **CVSS-Based Severity**: CRITICAL, HIGH, MEDIUM, LOW, INFO classification
- 🛡️ **14 Languages Supported**: Node.js, Python, React, PHP, Go, Java, .NET, Rust, Vue, React Native, Next.js, NestJS

## Installation

### Prerequisites
- Claude Code installed and running
- Access to a plugin marketplace

### Install from Marketplace

```bash
# Add the marketplace (replace with your marketplace URL)
/plugin marketplace add your-org/code-guardian

# Install the security plugin
/plugin install sec@your-org

# Verify installation
/plugin
```

### Install Locally for Development

```bash
# From the code-guardian directory
/plugin marketplace add ./

# Install the sec plugin
/plugin install sec@code-guardian
```

## Usage

### Basic Commands

```bash
# Full security scan
/scan --full

# Scan dependencies only (runs npm audit, pip-audit, etc.)
/scan --deps

# Scan specific files
/scan --files "src/**/*.js"

# Show only critical issues
/scan --severity critical

# Save report to file
/scan --full --output security-report.md
```

### What Gets Scanned

#### Code-Level Analysis
- SQL/NoSQL Injection
- Cross-Site Scripting (XSS)
- Command Injection
- Path Traversal
- Insecure Deserialization
- Weak Cryptography
- Hardcoded Secrets
- Authentication/Authorization Flaws
- CSRF Vulnerabilities

#### Dependency Analysis
- Known CVEs (via native tools + web search)
- Outdated package versions
- Transitive dependency vulnerabilities
- License compliance issues
- Deprecated packages
- Available exploits

#### Context-Aware Assessment
- Code path reachability analysis
- Attack surface mapping
- Data flow tracing
- Usage pattern detection

## Supported Technologies

| Technology | Security Patterns | Native Tool |
|------------|------------------|-------------|
| Node.js/JavaScript | Prototype pollution, ReDoS, command injection | `npm audit` |
| Python | Pickle deserialization, SSTI, eval injection | `pip-audit`, `safety check` |
| PHP | RCE, file inclusion, type juggling | `composer audit` |
| Go | Race conditions, SQL injection, SSRF | `govulncheck` |
| Java/Kotlin | Deserialization, XXE, SSRF | `mvn dependency-check:check` |
| .NET/C# | Unsafe deserialization, SQL injection | `dotnet list package --vulnerable` |
| Rust | Unsafe code blocks, memory safety | `cargo audit` |
| React | XSS, CSRF, sensitive data exposure | `npm audit` |
| Vue.js | XSS via v-html, template injection | `npm audit` |
| Next.js | API route security, server-side injection | `npm audit` |
| NestJS | Authentication bypass, SQL injection | `npm audit` |
| React Native | Insecure storage, API key exposure | `npm audit` |

## Severity Levels

- 🔴 **CRITICAL** (CVSS 9.0-10.0): RCE, auth bypass, exposed secrets
- 🟠 **HIGH** (CVSS 7.0-8.9): Privilege escalation, XSS, known exploits
- 🟡 **MEDIUM** (CVSS 4.0-6.9): CSRF, weak crypto, outdated deps
- 🔵 **LOW** (CVSS 0.1-3.9): Info leaks, deprecated functions
- ⚪ **INFO** (CVSS 0.0): Best practices, hardening tips

## Example Output

```
🔴 CRITICAL: SQL Injection in user authentication
├─ File: src/auth/login.js:45
├─ Pattern: String concatenation in SQL query
├─ Impact: Database compromise, data theft
└─ Fix: Use parameterized queries

⚠️ CONDITIONAL RISK: lodash v4.17.15
├─ Vulnerability: CVE-2020-8203 - Prototype Pollution
├─ Status: VULNERABLE CODE NOT USED IN PROJECT
├─ Risk Level: LOW (Theoretical) → Would be HIGH if used
└─ Recommendation: Upgrade to 4.17.21 in next maintenance window
```

## Plugin Structure

```
sec-workspace/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── agents/
│   └── sentinel.md          # Sentinel security agent
├── commands/
│   └── scan.md              # Security scan command
├── skills/
│   ├── SKILL.md             # Master security framework
│   ├── node_security.md     # Node.js security patterns
│   ├── python_security.md   # Python security patterns
│   ├── php_security.md      # PHP security patterns
│   ├── go_security.md       # Go security patterns
│   ├── java_security.md     # Java security patterns
│   ├── dotnet_security.md   # .NET security patterns
│   ├── rust_security.md     # Rust security patterns
│   ├── react_security.md    # React security patterns
│   ├── vue_security.md      # Vue.js security patterns
│   ├── next_security.md     # Next.js security patterns
│   ├── nest_security.md     # NestJS security patterns
│   ├── react_native_security.md  # React Native security
│   └── security_reference.md     # Security reference
└── README.md                # This file
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Security Scan
        run: code-guardian scan --full --severity high
      - name: Upload Report
        uses: actions/upload-artifact@v2
        with:
          name: security-report
          path: security-report.md
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
code-guardian scan --files "$(git diff --cached --name-only)"
```

## Configuration

### Environment Variables

```bash
# Optional: Configure custom vulnerability databases
SECURITY_NVD_API_KEY=your_nvd_api_key
SECURITY_SNYK_TOKEN=your_snyk_token

# Optional: Custom severity thresholds
SECURITY_MIN_SEVERITY=medium
SECURITY_FAIL_ON_CRITICAL=true
```

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [National Vulnerability Database](https://nvd.nist.gov/)
- [Snyk Vulnerability Database](https://security.snyk.io/)
- [GitHub Security Advisories](https://github.com/advisories)

## Contributing

To add new security patterns or improve existing ones:

1. Create new `[tech]_security.md` files in `skills/`
2. Update `SKILL.md` with references to new patterns
3. Enhance Sentinel agent capabilities in `sentinel.md`
4. Test thoroughly with real-world examples

## License

Part of the Code Guardian project by d4rkNinja.

## Support

For issues or questions:
- Review the comprehensive documentation in `skills/`
- Check technology-specific security guides
- Consult OWASP resources for best practices

---

🛡️ **Stay Secure with Sentinel!**
