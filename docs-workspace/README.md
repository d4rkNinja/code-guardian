# Documentation Workspace Plugin (docs)

**Comprehensive technical documentation generator for Claude Code**

## Overview

The **docs** plugin provides automated technical documentation generation through **DocBook**, an elite Technical Documentation Architect that analyzes codebases and generates comprehensive, structured project documentation.

## Features

- 📚 **Comprehensive Documentation**: Covers purpose, design, implementation, and maintenance
- 🔍 **Deep Code Analysis**: Understands architecture, design patterns, and business goals
- 🎯 **Technology-Specific**: Specialized analysis for 14+ languages/frameworks
- 📊 **Structured Output**: Consistent 5-point documentation framework
- 🚀 **Automated Generation**: Analyzes code and generates docs automatically
- 💡 **Insightful**: Connects implementation to architectural decisions

## Installation

### Prerequisites
- Claude Code installed and running
- Access to a plugin marketplace

### Install from Marketplace

```bash
# Add the marketplace (replace with your marketplace URL)
/plugin marketplace add your-org/code-guardian

# Install the docs plugin
/plugin install docs@your-org

# Verify installation
/plugin
```

### Install Locally for Development

```bash
# From the code-guardian directory
/plugin marketplace add ./

# Install the docs plugin
/plugin install docs@code-guardian
```

## Usage

### Basic Commands

```bash
# Generate documentation for current project
/review

# Review specific directory
/review --path src/

# Generate API documentation
/review --type api

# Create architecture documentation
/review --type architecture
```

### Documentation Framework

DocBook follows a comprehensive 5-point framework:

#### 1. Purpose, Scope & Context
- Why the project exists
- Problem statement & goals
- Target users & stakeholders
- In-scope vs out-of-scope
- Assumptions & constraints

#### 2. System Design & Organization
- Architecture structure
- High-level system design
- Major components/modules
- Data & control flow
- Design principles

#### 3. Implementation & Usage
- Build logic
- Project structure
- Key workflows
- Configuration & setup
- Usage examples

#### 4. Quality, Security & Reliability
- Correctness & safety
- Testing strategy
- Error handling
- Security measures
- Performance considerations

#### 5. Deployment, Maintenance & Evolution
- Runtime environment
- Build & release process
- Environment support
- Monitoring & logging
- Roadmap & future plans

## Supported Technologies

| Technology | Analysis Focus | Skill File |
|------------|---------------|------------|
| Node.js | Package.json, entry points, middleware chains | `node_docbook.md` |
| Python | Framework detection, async patterns, ORM | `python_docbook.md` |
| PHP | Composer, Laravel/Symfony patterns | `php_docbook.md` |
| Go | Module layout, concurrency patterns | `go_docbook.md` |
| Java/Kotlin | Build tools, DI graph, Spring patterns | `java_docbook.md` |
| .NET | Solution structure, DI, architecture patterns | `dotnet_docbook.md` |
| Rust | Crate types, module system, async runtime | `rust_docbook.md` |
| React | Component composition, state management | `react_docbook.md` |
| Vue.js | Options vs Composition API, Nuxt patterns | `vue_docbook.md` |
| Next.js | App vs Pages Router, data fetching | `next_docbook.md` |
| NestJS | DI graph, modules, decorators | `nest_docbook.md` |
| React Native | Navigation, native modules, Expo | `react_native_docbook.md` |

## Example Output

```markdown
# Project Documentation

## 1. Purpose, Scope & Context

### Why This Project Exists
This application provides a real-time collaboration platform for distributed teams...

### Problem Statement
Traditional communication tools lack context-aware features...

### Target Users
- Remote development teams
- Project managers
- Stakeholders requiring visibility

## 2. System Design & Organization

### Architecture
Microservices architecture with:
- API Gateway (Node.js/Express)
- Authentication Service (NestJS)
- Real-time Service (Socket.io)
- Database (PostgreSQL + Redis)

### Major Components
1. **API Gateway**: Routes requests, handles auth
2. **User Service**: Manages user profiles and permissions
3. **Collaboration Service**: Real-time document editing
...
```

## Plugin Structure

```
docs-workspace/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── agents/
│   └── docbook.md           # DocBook documentation agent
├── commands/
│   └── review.md            # Review/documentation command
├── skills/
│   ├── SKILL.md             # Master documentation framework
│   ├── node_docbook.md      # Node.js documentation patterns
│   ├── python_docbook.md    # Python documentation patterns
│   ├── php_docbook.md       # PHP documentation patterns
│   ├── go_docbook.md        # Go documentation patterns
│   ├── java_docbook.md      # Java documentation patterns
│   ├── dotnet_docbook.md    # .NET documentation patterns
│   ├── rust_docbook.md      # Rust documentation patterns
│   ├── react_docbook.md     # React documentation patterns
│   ├── vue_docbook.md       # Vue.js documentation patterns
│   ├── next_docbook.md      # Next.js documentation patterns
│   ├── nest_docbook.md      # NestJS documentation patterns
│   ├── react_native_docbook.md  # React Native documentation
│   └── reference.md         # Documentation reference
└── README.md                # This file
```

## Configuration

### Default Output Location

By default, documentation is generated in `docs/` directory in the project root. You can customize this:

```bash
# Specify custom output directory
/review --output ./documentation

# Generate in current directory
/review --output ./
```

### Documentation Style

DocBook adapts its style based on project type:
- **Libraries**: API-focused documentation
- **Applications**: User and developer guides
- **Services**: Architecture and deployment docs
- **Tools**: Usage and configuration guides

## CI/CD Integration

### GitHub Actions

```yaml
name: Generate Documentation
on:
  push:
    branches: [main]

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Generate Documentation
        run: code-guardian review --output ./docs
      - name: Commit Documentation
        run: |
          git config user.name "DocBot"
          git add docs/
          git commit -m "Update documentation" || echo "No changes"
          git push
```

## Best Practices

### When to Generate Documentation

- **Initial Setup**: Document architecture decisions
- **Major Features**: Document new components
- **Refactoring**: Update affected documentation
- **Before Releases**: Ensure docs are current
- **Onboarding**: Help new team members

### Documentation Maintenance

- Keep docs in sync with code
- Review generated docs for accuracy
- Add human insights where needed
- Version documentation with code
- Archive outdated documentation

## Resources

- [Technical Writing Best Practices](https://developers.google.com/tech-writing)
- [Documentation Guide](https://www.writethedocs.org/guide/)
- [Markdown Guide](https://www.markdownguide.org/)

## Contributing

To add new documentation patterns:

1. Create new `[tech]_docbook.md` files in `skills/`
2. Update `SKILL.md` with references to new patterns
3. Enhance DocBook agent capabilities in `docbook.md`
4. Test with real-world projects

## License

Part of the Code Guardian project by d4rkNinja.

## Support

For issues or questions:
- Review the comprehensive documentation in `skills/`
- Check technology-specific documentation guides
- Consult technical writing resources

---

📚 **Document Better with DocBook!**
