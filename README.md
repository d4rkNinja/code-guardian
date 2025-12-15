# 📚 Code Guardian - Advanced Documentation & Security Analysis Plugin

> **Version 1.0.0** - Deep Documentation Generation with Security Analysis Capabilities

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🔍 Overview

Code Guardian is an elite Claude Code plugin that transforms how you generate technical documentation and analyze code security. Leveraging advanced AI agents and deep analysis capabilities, it automatically produces comprehensive project documentation while performing multi-layered security assessments.

## 🚀 Key Features

### 📖 **Deep Documentation Generation**
- **DocBook Agent**: Elite technical documentation architect that synthesizes comprehensive project documentation
- **5-Point Framework**: Purpose & Context, System Design, Implementation, Quality & Security, Deployment & Maintenance
- **Multi-Language Support**: Specialized documentation for 10+ programming languages and frameworks
- **Code-Driven Analysis**: Generates documentation based on actual code evidence, not assumptions

### 🛡️ **Advanced Security Analysis**
- **Multi-Layer Security Scanning**:
  - Code vulnerability detection
  - Dependency security assessment
  - Configuration security analysis
  - Infrastructure security review
- **OWASP Top 10 Coverage**: Automated checks for common security vulnerabilities
- **Security Level Scoring**: Quantitative security assessment with detailed reports
- **Deep Agent Analysis**: Specialized agents for penetration testing, security auditing, and compliance checking

### 🤖 **Intelligent Agents**
- **DocBook Agent**: Technical documentation synthesis
- **Security Analysis Agents**: Deep security scanning and vulnerability assessment
- **Code Review Agents**: Automated code quality and security reviews
- **Tech Stack Detection**: Automatic identification of technologies, frameworks, and patterns

### 📊 **Comprehensive Reporting**
- **Executive Summaries**: High-level overview for stakeholders
- **Technical Deep Dives**: Detailed implementation guides
- **Security Assessment Reports**: Comprehensive security analysis
- **Roadmap & Recommendations**: Future-proofing and improvement suggestions

## 📦 Installation

### Method 1: Claude Code Marketplace (Recommended)
1. Open Claude Code
2. Run `/plugin` command
3. Navigate to "Select marketplace"
4. Search for "Code Guardian" or "doc-generator"
5. Use arrow keys + spacebar to select
6. Press 'i' to install

### Method 2: Direct GitHub Installation
```bash
# Clone the repository
git clone https://github.com/d4rkNinja/code-guardian.git

# Navigate to the plugin directory
cd code-guardian

# Install via Claude Code
claude plugin install .
```

### Method 3: Manual Installation
1. Download the latest release
2. Extract to `~/.claude/plugins/code-guardian/`
3. Restart Claude Code

## 🛠️ Configuration

Create a `.claude-plugin/config.json` in your project root:

```json
{
  "code-guardian": {
    "security_level": "comprehensive",
    "documentation_depth": "detailed",
    "output_format": "markdown",
    "scan_dependencies": true,
    "generate_diagrams": true,
    "security_scanning": {
      "enabled": true,
      "owasp_checks": true,
      "dependency_scan": true,
      "custom_rules": []
    }
  }
}
```

## 📋 Usage

### Generate Documentation
```bash
# Generate complete project documentation
/docbook

# Generate documentation for specific directory
/docbook ./src

# Generate documentation with security analysis
/docbook --security-scan
```

### Security Analysis
```bash
# Run comprehensive security scan
/security-scan

# Scan specific files
/security-scan ./src/**/*.js

# Generate security report
/security-report --format=pdf
```

### Multi-Language Support
Supported languages and frameworks:
- **Backend**: Node.js, Python, Java, .NET, Go, PHP, Rust
- **Frontend**: React, Vue.js, Angular, Next.js
- **Mobile**: React Native
- **Database**: PostgreSQL, MongoDB, Redis
- **Cloud**: AWS, Azure, GCP
- **DevOps**: Docker, Kubernetes, CI/CD

## 🔧 Plugin Structure

```
code-guardian/
├── .claude-plugin/
│   └── marketplace.json          # Plugin marketplace configuration
├── docs-workspace/
│   ├── plugin.json              # Main plugin configuration
│   ├── agents/
│   │   └── docbook.md           # DocBook agent configuration
│   ├── skills/
│   │   ├── SKILL.md             # Main skills configuration
│   │   ├── python_docbook.md    # Python documentation
│   │   ├── react_docbook.md     # React documentation
│   │   ├── rust_docbook.md      # Rust documentation
│   │   └── [other_languages]... # Language-specific docs
│   └── commands/
│       └── review.md            # Custom commands
└── README.md                    # This file
```

## 🔍 Documentation Framework

### The DocBook 5-Point Standard

1. **Purpose, Scope & Context**
   - Business value and problem statement
   - Target users and stakeholders
   - In-scope vs out-of-scope features
   - Assumptions and constraints

2. **System Design & Organization**
   - High-level architecture
   - Major components and modules
   - Data and control flow
   - Design principles and patterns

3. **Implementation & Usage**
   - Build logic and project structure
   - Key workflows and configurations
   - Usage examples and API documentation
   - Setup and installation guides

4. **Quality, Security & Reliability**
   - Testing strategies and coverage
   - Error handling and edge cases
   - Security measures and authentication
   - Performance optimization

5. **Deployment, Maintenance & Evolution**
   - Runtime environment and scaling
   - CI/CD pipelines and release process
   - Monitoring and troubleshooting
   - Roadmap and future improvements

## 🛡️ Security Features

### Multi-Layer Security Analysis

1. **Static Code Analysis**
   - Vulnerability pattern detection
   - Code quality assessment
   - Security anti-patterns identification

2. **Dependency Security**
   - Known vulnerability database checks
   - License compliance verification
   - Supply chain security assessment

3. **Configuration Security**
   - Environment variable analysis
   - Secret detection and exposure risks
   - Infrastructure security configuration

4. **Runtime Security**
   - Authentication and authorization analysis
   - Data encryption and transmission
   - API security assessment

### Security Reporting

- **Executive Security Summary**: High-level risk assessment
- **Technical Security Details**: Comprehensive vulnerability analysis
- **Remediation Recommendations**: Actionable security improvements
- **Compliance Reports**: Industry standard compliance verification

## 🔌 Extending the Plugin

### Adding New Language Support

1. Create a new language docbook file:
   ```markdown
   # [language]_docbook.md
   ---
   name: [language]-docbook
   description: [Language] specialized documentation agent
   skills: tech-specification
   ---
   ```

2. Add language-specific patterns and frameworks
3. Update `plugin.json` to include the new skill

### Custom Security Rules

Create custom security rules in `.claude-plugin/security-rules.json`:

```json
{
  "custom_rules": [
    {
      "id": "custom-hardcoded-secrets",
      "pattern": "password\\s*=\\s*['\"][^'\"]+['\"]",
      "severity": "high",
      "description": "Hardcoded password detected"
    }
  ]
}
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/d4rkNinja/code-guardian.git

# Install dependencies
npm install

# Run tests
npm test

# Build for development
npm run build:dev
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Claude Code team for the excellent plugin framework
- Security community for vulnerability databases and best practices
- All contributors and users who help improve this plugin

## 📞 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/d4rkNinja/code-guardian/issues)
- **Documentation**: [Full documentation](https://github.com/d4rkNinja/code-guardian/wiki)
- **Community**: [Discussions](https://github.com/d4rkNinja/code-guardian/discussions)

## 🔗 References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [MCP Server Documentation](https://github.com/modelcontextprotocol/servers)
- [OWASP Security Guidelines](https://owasp.org/)

---

**Code Guardian** - Elevating documentation standards and security in software development.

*Generated with ❤️ by [d4rkNinja](https://github.com/d4rkNinja)*