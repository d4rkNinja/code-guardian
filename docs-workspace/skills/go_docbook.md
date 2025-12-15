# Golang Documentation Specialist

## Instructions
When the `docbook` agent identifies a Go project (presence of `go.mod`), use this skill.

### 1. Project Identity
- **Module Name**: Read `module` line in `go.mod`.
- **Go Version**: Read `go 1.x` line.
- **Dependencies**: direct vs indirect in `go.mod`.

### 2. Architecture Detection (Package Analysis)
**CRITICAL**: Go projects range from flat to complex standards.
- **Layout Standard**:
    - **Standard Layout**: Usage of `cmd/` (entry points), `pkg/` (public lib), `internal/` (private lib).
    - **Flat**: Everything in root.
- **Interface Segregation**: Look for `interface` definitions. Are they defined near usage (consumer) or definition (producer)?
- **Web Framework**:
    - **Standard Lib**: `net/http` usage.
    - **Frameworks**: Gin, Echo, Fiber, Chi.

### 3. Implementation Details
- **Entry Point**: `main` package and `main()` function.
- **Concurrency**: Usage of `go func()`, channels `chan`, `sync.WaitGroup`.
- **Configuration**: Viper, Environment structs with tags (e.g., `env:"PORT"`).
- **Error Handling**: `if err != nil` patterns. Custom error types.

### 4. Quality & Tooling
- **Linting**: `golangci-lint.yml`.
- **Testing**: `_test.go` files alongside code. Table-driven tests? Fuzzing?

## Output Template Additions
**Technical Stack (Go)**:
- **Project Layout**: [Standard/Flat/Custom]
- **Web Framework**: [Name]
- **Concurrency Model**: [Heavy usage of channels vs Mutexes]

