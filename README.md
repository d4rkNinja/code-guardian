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
/plugin install docbook@d4rkNinja

# Security plugin
/plugin install sentinel@d4rkNinja
```

## Usage

### Using Agents

```bash
# Use Sentinel agent for security analysis
@sentinel "Analyze this codebase for security vulnerabilities"

# Scan specific file for vulnerabilities
@sentinel "Check src/auth/login.js for SQL injection vulnerabilities"

# Analyze dependencies
@sentinel "Scan package.json for vulnerable dependencies"

# Get security recommendations
@sentinel "What are the critical security issues in this project?"

# Use DocBook agent for documentation
@docbook "Generate technical documentation for this project"

# Document specific component
@docbook "Create API documentation for the user service"
```

## Language-Specific Skills

Both agents use **specialized skills** for each technology to provide accurate, context-aware analysis:

### Sentinel Security Skills
Each language has dedicated security patterns and vulnerability checks:

- **`node_security.md`** - Node.js/JavaScript (Express, Fastify)
  - Prototype pollution, ReDoS, command injection, JWT vulnerabilities
  - npm audit integration, dependency scanning
  
- **`python_security.md`** - Python (Django, Flask, FastAPI)
  - Pickle deserialization, SSTI, eval injection, SQL injection
  - pip-audit and safety check integration
  
- **`react_security.md`** - React/Frontend
  - XSS via dangerouslySetInnerHTML, CSRF, sensitive data exposure
  - CSP headers, secure authentication patterns
  
- **`php_security.md`** - PHP (Laravel, WordPress)
  - RCE, file inclusion, type juggling, deserialization
  - composer audit integration
  
- **`go_security.md`** - Go
  - Race conditions, SQL injection, SSRF, unsafe reflection
  - govulncheck integration
  
- **`java_security.md`** - Java/Kotlin (Spring Boot)
  - Deserialization, XXE, SSRF, SpEL injection
  - Maven/Gradle dependency-check integration
  
- **`dotnet_security.md`** - .NET/C# (ASP.NET Core)
  - Unsafe deserialization, SQL injection, XSS, CSRF
  - dotnet package vulnerability scanning
  
- **`rust_security.md`** - Rust
  - Unsafe code blocks, memory safety, integer overflow
  - cargo audit integration
  
- **`vue_security.md`** - Vue.js
  - XSS via v-html, template injection, Vuex security
  
- **`next_security.md`** - Next.js
  - API route security, server-side injection, CSRF
  - App Router and Pages Router patterns
  
- **`nest_security.md`** - NestJS
  - Authentication bypass, SQL injection, missing guards
  - TypeORM/Mongoose security patterns
  
- **`react_native_security.md`** - React Native
  - Insecure storage, API key exposure, deep linking
  - Certificate pinning, jailbreak detection

### DocBook Documentation Skills
Each language has specialized documentation templates:

- **`node_docbook.md`**, **`python_docbook.md`**, **`php_docbook.md`**, etc.
- Framework-specific patterns (Express, Django, Laravel, Spring Boot)
- API documentation, architecture diagrams, deployment guides

**To get the most accurate results**, mention the specific technology in your query:
```bash
@sentinel "Analyze this Node.js Express app for security issues"
@sentinel "Check this Django view for SQL injection"
@docbook "Generate documentation for this Spring Boot microservice"
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