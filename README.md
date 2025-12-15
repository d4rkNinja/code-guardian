# 📚 Docs Plugin - Technical Documentation Generator for Claude Code

> **Version 1.0.0** - Advanced code review and documentation generation plugin

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🔍 Overview

The Docs Plugin is a comprehensive Claude Code plugin that provides intelligent code review, bug detection, and automated documentation generation capabilities. It leverages specialized agents and skills to analyze your codebase and generate high-quality technical documentation.

## 🚀 Features

### 📖 **Documentation Generation**
- **DocBook Agent**: Specialized technical documentation generator
- **Comprehensive Analysis**: Deep understanding of code architecture and patterns
- **Multi-Format Output**: Generates structured markdown documentation
- **Language Agnostic**: Works with any programming language or framework

### 🐛 **Code Review & Bug Detection**
- **Automated Code Review**: Identifies potential bugs and improvements
- **Best Practices Analysis**: Ensures code follows industry standards
- **Security Vulnerability Detection**: Identifies common security issues
- **Performance Recommendations**: Suggests optimization opportunities

### 🤖 **Intelligent Agents**
- **DocBook Agent**: Elite technical documentation architect
- **Code Review Agent**: Automated code quality analysis
- **Specialized Skills**: Language-specific documentation templates

## 📦 Installation

### Method 1: Claude Code Marketplace (Recommended)
1. Open Claude Code
2. Run `/plugin` command
3. Navigate to "Select marketplace"
4. Search for "docs" plugin
5. Use arrow keys + spacebar to select
6. Press 'i' to install

### Method 2: Direct GitHub Installation
```bash
# Clone the repository
git clone https://github.com/d4rkNinja/code-guardian.git

# Navigate to the plugin directory
cd code-guardian

# Install via Claude Code
claude plugin install ./docs-workspace
```

### Method 3: Manual Installation
1. Download the plugin files
2. Create a directory in your plugins folder: `~/.claude/plugins/docs/`
3. Copy all files from `docs-workspace/` to the plugin directory
4. Restart Claude Code

## 🛠️ Plugin Structure

```
docs-workspace/
├── plugin.json              # Main plugin configuration
├── agents/
│   └── docbook.json         # DocBook agent configuration
├── skills/
│   ├── SKILL.md            # Main skills configuration
│   ├── python_docbook.md   # Python documentation
│   ├── react_docbook.md    # React documentation
│   ├── vue_docbook.md      # Vue documentation
│   ├── rust_docbook.md     # Rust documentation
│   ├── node_docbook.md     # Node.js documentation
│   ├── java_docbook.md     # Java documentation
│   ├── dotnet_docbook.md   # .NET documentation
│   ├── go_docbook.md       # Go documentation
│   ├── php_docbook.md      # PHP documentation
│   ├── nest_docbook.md     # NestJS documentation
│   ├── next_docbook.md     # Next.js documentation
│   ├── react_native_docbook.md # React Native documentation
│   └── reference.md        # Technical reference
└── commands/
    └── review.md           # Custom commands
```

## 📋 Usage

### Generate Documentation
```bash
# Generate complete project documentation
/docs

# Generate documentation for specific component
/docs ./src/components

# Generate documentation with custom settings
/docs --format=markdown --output=./docs
```

### Code Review
```bash
# Run code review on entire project
/review

# Review specific files
/review ./src/**/*.js

# Review with focus on security
/review --security
```

### Language-Specific Documentation
The plugin includes specialized documentation skills for:

- **Backend**: Python, Node.js, Java, .NET, Go, PHP, Rust
- **Frontend**: React, Vue.js, Next.js
- **Mobile**: React Native
- **Frameworks**: NestJS

## 🔧 Configuration

Create a `.docs-config.json` in your project root:

```json
{
  "output": {
    "directory": "./docs",
    "format": "markdown",
    "include_diagrams": true
  },
  "analysis": {
    "depth": "deep",
    "include_tests": true,
    "security_scan": true
  },
  "documentation": {
    "style": "comprehensive",
    "include_examples": true,
    "api_docs": true
  }
}
```

## 📊 Documentation Framework

### The DocBook 5-Point Standard

1. **Purpose, Scope & Context**
   - Business value and problem statement
   - Target users and stakeholders
   - Project boundaries and constraints

2. **System Design & Organization**
   - High-level architecture
   - Component breakdown
   - Data flow and patterns

3. **Implementation & Usage**
   - Build and setup instructions
   - Code structure explanation
   - Usage examples

4. **Quality, Security & Reliability**
   - Testing strategies
   - Error handling
   - Security measures

5. **Deployment, Maintenance & Evolution**
   - Runtime environment
   - CI/CD processes
   - Monitoring and roadmap

## 🔍 Plugin Components

### Plugin Configuration (plugin.json)
```json
{
  "name": "docs",
  "description": "Reviews code for bugs and improvements",
  "version": "1.0.0",
  "author": {"name": "d4rkNinja"},
  "commands": ["./commands/review.md"],
  "agents": ["./agents/docbook.json"],
  "skills": ["./skills/SKILL.md"]
}
```

### DocBook Agent
- **Purpose**: Specialized technical documentation generation
- **Model**: Inherits from Claude Code's default model
- **Skills**: tech-specification
- **Permission Mode**: default

### Skills System
The plugin includes multiple specialized skills:
- **Main Skill**: Core documentation and review capabilities
- **Language-Specific Skills**: Tailored documentation for each language/framework
- **Reference Materials**: Technical specifications and best practices

## 🎯 Best Practices

### For Documentation Generation
1. **Clean Code**: Well-structured code produces better documentation
2. **Comments**: Include meaningful comments for complex logic
3. **Consistent Naming**: Use clear, descriptive names
4. **Modular Structure**: Organize code into logical modules

### For Code Review
1. **Run Before Commits**: Use `/review` before committing changes
2. **Fix Identified Issues**: Address all high-priority issues
3. **Update Documentation**: Keep documentation synchronized with code
4. **Team Standards**: Ensure team follows consistent practices

## 🔌 Extending the Plugin

### Adding New Commands
1. Create new command file in `commands/`
2. Update `plugin.json` to include the command
3. Test with Claude Code

### Adding New Skills
1. Create skill file in `skills/`
2. Follow the established skill template
3. Update `plugin.json` to reference the skill

### Custom Agents
1. Create agent configuration in `agents/`
2. Define agent capabilities and permissions
3. Update `plugin.json` to include the agent

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Claude Code team for the excellent plugin system
- Contributors who help improve the plugin
- The open-source community for inspiration

## 📞 Support

- **GitHub Issues**: [Report bugs and request features](https://github.com/d4rkNinja/code-guardian/issues)
- **Documentation**: [Full documentation](https://github.com/d4rkNinja/code-guardian/wiki)
- **Community**: [Discussions](https://github.com/d4rkNinja/code-guardian/discussions)

## 🔗 References

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Claude Code Settings](https://code.claude.com/docs/en/settings)

---

**Docs Plugin** - Intelligent code review and documentation generation for Claude Code.

*Generated with ❤️ by [d4rkNinja](https://github.com/d4rkNinja)*