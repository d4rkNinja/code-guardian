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

## Installation

### Add Marketplace
```bash
/plugin marketplace add d4rkNinja/code-guardian
```

### Install Plugins
```bash
# Security plugin (Install First - Critical)
/plugin install sentinel@d4rkNinja

# Test generation plugin (Install Second - High Priority)
/plugin install testsmith@d4rkNinja

# Documentation plugin (Install Third - Standard)
/plugin install docbook@d4rkNinja
```

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

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Code Guardian** by [d4rkNinja](https://github.com/d4rkNinja)
