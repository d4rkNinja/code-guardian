# Code Guardian

Claude plugins for security analysis, test case generation, and documentation.

## Plugins

### 🛡️ sentinel - Security Scanner  
**Priority: Critical**  
Comprehensive security vulnerability scanner with deep analysis and intelligent remediation strategies.

### 🧪 testsmith - Test Case Generator  
**Priority: High**  
Intelligent test automation that generates high-quality integration and API tests, focusing on critical business logic.

### 📚 docbook - Documentation Generator
**Priority: Standard**  
Automated technical documentation generation for comprehensive project understanding.

## Prerequisites

Before installing Code Guardian plugins, ensure you have:

- **Operating System**: Windows, macOS, or Linux
- **Internet Connection**: Required for downloading Claude Code and plugins
- **Claude Account**: Sign up at [claude.ai](https://claude.ai) if you don't have one
- **Basic Command Line Knowledge**: Familiarity with terminal/command prompt

## Installation

### Step 1: Install Claude Code

Claude Code is required to use Code Guardian plugins. Follow these steps:

#### Windows

1. **Download Claude Code**
   - Visit the [Claude Code download page](https://claude.ai/download)
   - Download the Windows installer (`.exe` file)

2. **Run the Installer**
   - Double-click the downloaded installer
   - Follow the installation wizard
   - Accept the license agreement
   - Choose installation location (default recommended)

3. **Launch Claude Code**
   - Open Claude Code from Start Menu or Desktop shortcut
   - Sign in with your Claude account

#### macOS

1. **Download Claude Code**
   - Visit the [Claude Code download page](https://claude.ai/download)
   - Download the macOS installer (`.dmg` file)

2. **Install the Application**
   - Open the downloaded `.dmg` file
   - Drag Claude Code to your Applications folder
   - Eject the installer disk image

3. **Launch Claude Code**
   - Open Claude Code from Applications
   - If prompted about security, go to System Preferences → Security & Privacy → Allow
   - Sign in with your Claude account

#### Linux

1. **Download Claude Code**
   - Visit the [Claude Code download page](https://claude.ai/download)
   - Download the Linux package (`.deb`, `.rpm`, or `.AppImage`)

2. **Install the Package**
   
   For Debian/Ubuntu (`.deb`):
   ```bash
   sudo dpkg -i claude-code_*.deb
   sudo apt-get install -f  # Install dependencies if needed
   ```

   For Fedora/RHEL (`.rpm`):
   ```bash
   sudo rpm -i claude-code-*.rpm
   ```

   For AppImage:
   ```bash
   chmod +x Claude-Code-*.AppImage
   ./Claude-Code-*.AppImage
   ```

3. **Launch Claude Code**
   - Run `claude-code` from terminal or application menu
   - Sign in with your Claude account

### Step 2: Install Code Guardian Plugins

Once Claude Code is installed and running, install the Code Guardian plugins:

#### Method 1: Using Plugin Marketplace (Recommended)

1. **Add the Code Guardian Marketplace**
   
   Open Claude Code and run the following command in the chat:
   ```bash
   /plugin marketplace add d4rkNinja/code-guardian
   ```
   
   This adds the Code Guardian plugin repository to your available marketplaces.

2. **Install Plugins in Priority Order**

   Install the plugins one by one in the recommended order:

   **a) Install Sentinel (Security Scanner) - CRITICAL PRIORITY**
   ```bash
   /plugin install sentinel@d4rkNinja
   ```
   Wait for installation to complete before proceeding.

   **b) Install TestSmith (Test Generator) - HIGH PRIORITY**
   ```bash
   /plugin install testsmith@d4rkNinja
   ```
   Wait for installation to complete before proceeding.

   **c) Install DocBook (Documentation Generator) - STANDARD PRIORITY**
   ```bash
   /plugin install docbook@d4rkNinja
   ```

3. **Verify Installation**
   
   Check that all plugins are installed correctly:
   ```bash
   /plugin list
   ```
   
   You should see:
   - ✅ sentinel@d4rkNinja
   - ✅ testsmith@d4rkNinja
   - ✅ docbook@d4rkNinja

#### Method 2: Manual Installation (Alternative)

If the marketplace method doesn't work, you can install plugins manually:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/d4rkNinja/code-guardian.git
   ```

2. **Navigate to Plugin Directory**
   ```bash
   cd code-guardian
   ```

3. **Install Each Plugin**
   ```bash
   /plugin install ./sec-workspace
   /plugin install ./testcases-workspace
   /plugin install ./docs-workspace
   ```

### Step 3: Configure Your Workspace

1. **Open Your Project in Claude Code**
   - File → Open Folder
   - Select your project directory

2. **Verify Plugin Access**
   
   Test each plugin with a simple command:
   ```bash
   @sentinel "Check if you're working"
   @testsmith "Check if you're working"
   @docbook "Check if you're working"
   ```

3. **Start Using Code Guardian**
   
   You're all set! Refer to the [Usage](#usage) section below for examples.


## Usage

### Priority 1: Security Analysis with Sentinel

```bash
# Comprehensive security scan
@sentinel "Analyze this codebase for security vulnerabilities"

# Scan specific file for vulnerabilities
@sentinel "Check src/auth/login.js for SQL injection vulnerabilities"

# Analyze dependencies
@sentinel "Scan package.json for vulnerable dependencies"

# Get security recommendations
@sentinel "What are the critical security issues in this project?"
```

### Priority 2: Test Case Generation with TestSmith

```bash
# Generate API tests
@testsmith "Generate integration tests for the user API endpoints"

# Generate service layer tests
@testsmith "Create tests for the PaymentService focusing on main workflows"

# Generate workflow tests
@testsmith "Write tests for the order fulfillment process"

# Generate complete test suite
@testsmith "Generate comprehensive test suite for this Express application"

# Framework-specific
@testsmith "Generate Jest tests for my Next.js API routes"
@testsmith "Create Pytest tests for FastAPI endpoints"
```

### Priority 3: Documentation with DocBook

```bash
# Generate technical documentation
@docbook "Generate technical documentation for this project"

# Document specific component
@docbook "Create API documentation for the user service"
```

## Language-Specific Skills

All agents use **specialized skills** for each technology to provide accurate, context-aware analysis. Skills are organized by priority.

### Priority 1: Sentinel Security Skills
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

### Priority 2: TestSmith Testing Skills
Each language has specialized test generation patterns focusing on **integration tests**, **API testing**, and **main function workflows**:

- **`node_testing.md`** - Node.js/JavaScript
  - **Frameworks**: Jest, Vitest, Mocha + Chai
  - **API Testing**: Supertest for Express/Fastify/NestJS
  - **Focus**: API endpoints, service layer, async workflows
  - **Database**: MongoDB (mongodb-memory-server), PostgreSQL (testcontainers)
  - **Patterns**: Mock external APIs, test factories, integration over unit tests

- **`python_testing.md`** - Python
  - **Frameworks**: Pytest (primary), unittest
  - **API Testing**: FastAPI TestClient, Django test client, Flask test client
  - **Focus**: REST APIs, service methods, business workflows
  - **Database**: SQLite in-memory, pytest fixtures
  - **Patterns**: Parametrized tests, fixtures for setup/teardown, mock external services

- **`java_testing.md`** - Java/Kotlin (Coming Soon)
  - **Frameworks**: JUnit 5, Mockito, Spring Boot Test
  - **API Testing**: MockMvc, RestAssured
  - **Focus**: REST controllers, service layer, Spring beans
  - **Patterns**: @SpringBootTest, TestContainers, integration slices

- **`dotnet_testing.md`** - .NET/C# (Coming Soon)
  - **Frameworks**: xUnit, NUnit, MSTest, FluentAssertions
  - **API Testing**: WebApplicationFactory, HttpClient
  - **Focus**: API controllers, service layer, EF Core operations
  - **Patterns**: In-memory databases, mocking with Moq

- **`go_testing.md`** - Go (Coming Soon)
  - **Frameworks**: testing package, testify
  - **API Testing**: httptest for handlers
  - **Focus**: HTTP handlers, service functions, table-driven tests
  - **Patterns**: Subtests, test fixtures, mock interfaces

- **`php_testing.md`** - PHP (Coming Soon)
  - **Frameworks**: PHPUnit, Pest (Laravel)
  - **API Testing**: Laravel HTTP tests, Symfony test client
  - **Focus**: API routes, service classes, Eloquent operations
  - **Patterns**: Database factories, feature tests, mocking facades

- **`rust_testing.md`** - Rust (Coming Soon)
  - **Frameworks**: Built-in test framework, mockall
  - **API Testing**: Rocket/Actix test utilities
  - **Focus**: HTTP handlers, business logic, integration tests
  - **Patterns**: Module tests, integration test directory, cargo test

### Priority 3: DocBook Documentation Skills
Each language has specialized documentation templates:

- **`node_docbook.md`**, **`python_docbook.md`**, **`php_docbook.md`**, etc.
- Framework-specific patterns (Express, Django, Laravel, Spring Boot)
- API documentation, architecture diagrams, deployment guides

**To get the most accurate results**, mention the specific technology in your query:
```bash
# Security Analysis
@sentinel "Analyze this Node.js Express app for security issues"
@sentinel "Check this Django view for SQL injection"

# Test Generation
@testsmith "Generate Jest tests for my Express API endpoints"
@testsmith "Create Pytest integration tests for FastAPI services"
@testsmith "Write tests for my NestJS payment service"

# Documentation
@docbook "Generate documentation for this Spring Boot microservice"
```

## Supported Technologies

All three plugins (Sentinel, TestSmith, DocBook) support the following 12+ languages/frameworks:
- **Backend**: Node.js, Python, PHP, Go, Java/Kotlin, .NET/C#, Rust
- **Frontend**: React, Vue.js, Next.js
- **Full-Stack**: NestJS
- **Mobile**: React Native

## Key Features

### 🛡️ Sentinel - Security Analysis
- **Vulnerability Detection**: OWASP Top 10, CWE patterns, framework-specific exploits
- **Dependency Scanning**: CVE database integration, version analysis, exploit detection
- **Context-Aware Risk Assessment**: Real exploitability analysis, attack surface mapping
- **Intelligent Remediation**: Version upgrades, code fixes, security hardening
- **Comprehensive Reports**: Generated in `sec-reports/` with severity classification

### 🧪 TestSmith - Test Case Generation
- **Smart Test Prioritization**: Focus on APIs, services, and main workflows (not utilities)
- **Integration-First Approach**: Emphasizes integration tests over unit tests
- **Framework-Specific Patterns**: Jest, Pytest, JUnit, xUnit, Go testing, etc.
- **Complete Test Suites**: Includes setup, teardown, fixtures, and mocking
- **Test Documentation**: Generated in `test-reports/` with coverage strategy
- **Best Testing Practices**: AAA pattern, test isolation, realistic data

### 📚 DocBook - Documentation
- **Evidence-Based Analysis**: Infers architecture from actual code structure
- **Multi-Domain Coverage**: Purpose, architecture, implementation, security, operations
- **Structured Output**: Separate files for each domain in `docs/` directory
- **Code-Driven Insights**: No generic boilerplate, only verified information

## Troubleshooting

### Installation Issues

#### Claude Code Won't Install

**Problem**: Installer fails or won't launch

**Solutions**:
- **Windows**: Run installer as Administrator (right-click → Run as administrator)
- **macOS**: Check System Preferences → Security & Privacy for blocked apps
- **Linux**: Ensure you have required dependencies installed
- Temporarily disable antivirus software during installation
- Download the installer again (file may be corrupted)

#### Plugin Installation Fails

**Problem**: `/plugin install` command returns an error

**Solutions**:
1. **Check Internet Connection**: Plugins require internet to download
2. **Verify Marketplace**: Ensure marketplace is added first:
   ```bash
   /plugin marketplace list
   ```
   If `d4rkNinja/code-guardian` is not listed, add it:
   ```bash
   /plugin marketplace add d4rkNinja/code-guardian
   ```
3. **Check Plugin Name**: Ensure correct syntax:
   ```bash
   /plugin install sentinel@d4rkNinja
   ```
4. **Clear Plugin Cache**: Remove and reinstall:
   ```bash
   /plugin uninstall sentinel@d4rkNinja
   /plugin install sentinel@d4rkNinja
   ```

### Usage Issues

#### Plugin Not Responding

**Problem**: `@sentinel`, `@testsmith`, or `@docbook` commands don't work

**Solutions**:
1. **Verify Plugin is Installed**:
   ```bash
   /plugin list
   ```
   If not listed, install the plugin

2. **Check Plugin Status**:
   ```bash
   /plugin status sentinel@d4rkNinja
   ```

3. **Restart Claude Code**: Close and reopen the application

4. **Reinstall Plugin**:
   ```bash
   /plugin uninstall sentinel@d4rkNinja
   /plugin install sentinel@d4rkNinja
   ```

#### Reports Not Generating

**Problem**: Sentinel/TestSmith/DocBook runs but doesn't create report files

**Solutions**:
- **Check Workspace Permissions**: Ensure Claude Code has write access to your project directory
- **Verify Output Directory**: Check if `sec-reports/`, `test-reports/`, or `docs/` folders exist
- **Review Agent Output**: Look for error messages in the response
- **Try Specific Commands**: Instead of general requests, use specific file/component targets

#### Incomplete Analysis

**Problem**: Agent only analyzes some files or provides partial results

**Solutions**:
- **Be Specific**: Mention the scope clearly:
  ```bash
  @sentinel "Analyze the entire codebase for security vulnerabilities"
  @testsmith "Generate tests for all API endpoints in src/api/"
  ```
- **Check File Permissions**: Ensure all project files are readable
- **Large Codebases**: For very large projects, analyze in chunks:
  ```bash
  @sentinel "Analyze authentication module in src/auth/"
  @sentinel "Analyze API routes in src/routes/"
  ```

### Performance Issues

#### Slow Analysis

**Problem**: Plugins take too long to complete analysis

**Solutions**:
- **Reduce Scope**: Analyze specific modules instead of entire codebase
- **Close Other Applications**: Free up system resources
- **Check Internet Speed**: Web searches for CVEs/best practices require good connection
- **Upgrade Claude Plan**: Higher-tier plans may have better performance

### Common Error Messages

#### "Permission Denied"

**Cause**: Claude Code doesn't have write access to project directory

**Solution**: 
- **Windows**: Run Claude Code as Administrator
- **macOS/Linux**: Check folder permissions:
  ```bash
  chmod -R u+w /path/to/project
  ```

#### "Marketplace Not Found"

**Cause**: Marketplace URL is incorrect or not added

**Solution**:
```bash
/plugin marketplace add d4rkNinja/code-guardian
```

#### "Plugin Already Installed"

**Cause**: Trying to install an already installed plugin

**Solution**: This is not an error. Plugin is ready to use. If it's not working, try:
```bash
/plugin reload sentinel@d4rkNinja
```

### Getting Help

If you encounter issues not covered here:

1. **Check Plugin Documentation**: Review the agent-specific documentation in each workspace
2. **GitHub Issues**: Report bugs at [github.com/d4rkNinja/code-guardian/issues](https://github.com/d4rkNinja/code-guardian/issues)
3. **Claude Support**: Contact Claude support for Claude Code specific issues
4. **Community**: Join discussions and ask questions in the repository discussions

## Future Work

### Security (Sentinel)
- [ ] Add more language-specific security patterns
- [ ] Integrate with CI/CD pipelines
- [ ] Add custom rule configuration
- [ ] Real-time vulnerability monitoring

### Testing (TestSmith)
- [ ] Complete testing skills for Java, .NET, Go, PHP, Rust
- [ ] Add E2E testing patterns (Cypress, Playwright, Selenium)
- [ ] Generate mutation tests for critical functions
- [ ] AI-powered test case suggestions based on code changes
- [ ] Performance and load testing patterns

### Documentation (DocBook)
- [ ] Support for more frameworks
- [ ] Enhanced reporting formats (PDF, HTML)
- [ ] Interactive architecture diagrams
- [ ] Changelog generation

### General
- [ ] Team collaboration features
- [ ] Plugin marketplace submission
- [ ] VS Code extension integration
- [ ] Automated PR comments with analysis results

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Code Guardian** by [d4rkNinja](https://github.com/d4rkNinja)
