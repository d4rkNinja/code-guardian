# Code Guardian

Claude Code plugins for documentation generation and security analysis.

## Plugins

### � docs - Documentation Generator
Automated technical documentation generation with DocBook agent.

### 🛡️ sec - Security Scanner  
Comprehensive security vulnerability scanner with Sentinel agent.

## Installation

### Add Marketplace
```bash
/plugin marketplace add d4rkNinja/code-guardian
```

### Install Plugins
```bash
# Documentation plugin
/plugin install docs@d4rkNinja

# Security plugin
/plugin install sec@d4rkNinja
```

## Usage

### Documentation Plugin
```bash
# Generate documentation
/review

# Review specific directory
/review --path src/
```

### Security Plugin
```bash
# Full security scan
/scan --full

# Scan dependencies only
/scan --deps

# Scan specific files
/scan --files "src/**/*.js"

# Critical issues only
/scan --severity critical
```

## Supported Technologies

Both plugins support 14 languages/frameworks:
- **Backend**: Node.js, Python, PHP, Go, Java, .NET, Rust
- **Frontend**: React, Vue.js, Next.js
- **Full-Stack**: NestJS
- **Mobile**: React Native

## Future Work

- [ ] Add more language-specific security patterns
- [ ] Integrate with CI/CD pipelines
- [ ] Add custom rule configuration
- [ ] Support for more frameworks
- [ ] Enhanced reporting formats
- [ ] Real-time vulnerability monitoring
- [ ] Team collaboration features
- [ ] Plugin marketplace submission

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Code Guardian** by [d4rkNinja](https://github.com/d4rkNinja)