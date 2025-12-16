---
description: Scan codebase for security vulnerabilities and generate comprehensive security report
---

# Security Scan Command

This command initiates a comprehensive security analysis of your codebase using the **Sentinel** agent.

## Usage

```
/scan [options]
```

## Options

- `--full`: Perform full codebase scan (all files)
- `--deps`: Scan dependencies only
- `--files <pattern>`: Scan specific files or patterns
- `--severity <level>`: Filter by severity (critical, high, medium, low)
- `--output <path>`: Save report to specific location

## Examples

### Full Security Scan
```
/scan --full
```
Performs comprehensive analysis of all source files and dependencies.

### Dependency Scan Only
```
/scan --deps
```
Analyzes package dependencies for known CVEs and outdated versions.

### Scan Specific Files
```
/scan --files "src/auth/**/*.js"
```
Scans only authentication-related files.

### Critical Issues Only
```
/scan --severity critical
```
Shows only critical severity vulnerabilities.

## What Gets Scanned

### 1. Source Code Analysis
- **Injection Vulnerabilities**: SQL, NoSQL, Command, XSS, SSTI
- **Authentication Flaws**: Weak password handling, session issues
- **Cryptographic Issues**: Weak algorithms, hardcoded secrets
- **Input Validation**: Missing sanitization, type issues
- **Error Handling**: Information disclosure
- **Business Logic**: Race conditions, TOCTOU
- **Configuration**: Insecure settings, debug mode

### 2. Dependency Analysis
- **CVE Identification**: Known vulnerabilities in packages
- **Version Analysis**: Outdated packages with security patches
- **Transitive Dependencies**: Indirect dependency vulnerabilities
- **License Compliance**: Restrictive or incompatible licenses
- **Deprecation Status**: Abandoned packages
- **Exploit Availability**: Public exploits for identified CVEs

### 3. Context-Aware Assessment
- **Code Path Analysis**: Is vulnerable code actually used?
- **Attack Surface**: Exposed endpoints and entry points
- **Data Flow**: Sensitive data tracking
- **Privilege Context**: Permission levels
- **Network Exposure**: Remote exploitability
- **Usage Patterns**: Are vulnerable features actually used?

## Output Format

The scan generates a comprehensive security report with:

### Executive Summary
- Total vulnerabilities found
- Breakdown by severity
- Immediate action items
- Overall security posture

### Critical Findings
Detailed analysis of critical vulnerabilities requiring immediate attention.

### Detailed Analysis
- **File-Level Issues**: Specific code vulnerabilities with line numbers
- **Dependency Issues**: Package vulnerabilities with CVE details
- **Context Analysis**: Real-world exploitability assessment

### Remediation Roadmap
Prioritized action plan with:
- Immediate fixes (0-24 hours)
- Short-term fixes (1-7 days)
- Medium-term improvements (1-4 weeks)
- Long-term enhancements (1-3 months)

### Verification Steps
How to test that fixes work correctly.

## Severity Levels

🔴 **CRITICAL** (CVSS 9.0-10.0)
- Remote code execution
- Authentication bypass
- SQL injection in production
- Exposed credentials

🟠 **HIGH** (CVSS 7.0-8.9)
- Privilege escalation
- Sensitive data exposure
- XSS in authenticated areas
- Known exploits available

🟡 **MEDIUM** (CVSS 4.0-6.9)
- CSRF vulnerabilities
- Information disclosure
- Weak cryptography
- Outdated dependencies

🔵 **LOW** (CVSS 0.1-3.9)
- Minor information leaks
- Deprecated functions
- Code quality issues

⚪ **INFO** (CVSS 0.0)
- Best practice recommendations
- Hardening opportunities

## Special Features

### Unused Vulnerability Detection
Sentinel identifies when a package has vulnerabilities but the vulnerable code is not used in your project:

```
⚠️ CONDITIONAL RISK: lodash v4.17.15
├─ Vulnerability: CVE-2020-8203 - Prototype Pollution
├─ Severity: HIGH
├─ Status: VULNERABLE CODE NOT USED IN PROJECT
├─ Analysis: The vulnerable _.merge() function is present but not
│  imported or called anywhere in the codebase.
├─ Recommendation: 
│  ├─ IMMEDIATE: Monitor for future usage
│  ├─ SHORT-TERM: Upgrade to 4.17.21 in next maintenance window
│  └─ LONG-TERM: Consider alternative packages
└─ Risk Level: LOW (Theoretical) → Would be HIGH if used
```

### Web Search Integration
Sentinel automatically searches online for:
- Current CVE databases
- Package security advisories
- Latest stable versions
- Known exploits
- Security best practices

## Best Practices

1. **Run Regularly**: Scan before each release
2. **Automate**: Integrate into CI/CD pipeline
3. **Prioritize**: Address critical/high issues first
4. **Verify**: Test fixes in staging environment
5. **Document**: Keep security audit trail
6. **Update**: Keep Sentinel's vulnerability database current

## Integration with CI/CD

### GitHub Actions Example
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
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit
code-guardian scan --files "$(git diff --cached --name-only)"
```

## Troubleshooting

### False Positives
If Sentinel reports a false positive:
1. Review the context analysis
2. Check if the code path is actually reachable
3. Document why it's a false positive
4. Consider adding to ignore list

### Performance
For large codebases:
- Use `--files` to scan incrementally
- Run full scans nightly
- Cache dependency analysis results

## Support

For issues or questions about security scanning:
- Review the security analysis framework
- Check technology-specific security guides
- Consult OWASP resources
- Reach out to the security team

---

**Remember**: Security is a continuous process, not a one-time task. Regular scans and prompt remediation are essential for maintaining a secure codebase.
