# Rust Documentation Specialist

## Instructions
When the `docbook` agent identifies a Rust project (presence of `Cargo.toml`), use this skill.

### 1. Project Identity
- **Package Type**:
    - **Binary**: `src/main.rs`.
    - **Library**: `src/lib.rs`.
    - **Workspace**: `Cargo.toml` contains `[workspace]`.
- **Edition**: Check `edition = "2021"` (or other) in manifest.

### 2. Architecture Detection (Crate Analysis)
**CRITICAL**: Analyze the module system.
- **Async Runtime**: Usage of `tokio`, `async-std`. Look for `#[tokio::main]`.
- **Module Structure**:
    - `mod.rs` (legacy) vs file-system modules.
    - Public vs Private API (`pub mod`, `pub use`).
- **Web Architectures**:
    - **Axum/Actix/Rocket**: Look for route handlers and extractor patterns.
    - **State Management**: Usage of `Arc<Mutex<T>>` or `RwLock` for shared component state.

### 3. Implementation Details
- **Error Handling**: Usage of `Result<T, E>`, `anyhow`, `thiserror`.
- **Data Access**: `diesel`, `sqlx` (look for `.sql` files or macros), `sea-orm`.
- **Configuration**: `config` crate, `serde` deserialization of config files.

### 4. Quality & Tooling
- **Linting**: `clippy` configuration.
- **Formatting**: `rustfmt.toml`.
- **Testing**: Unit tests in same file (`#[cfg(test)]`) vs Integration tests in `tests/` folder.

## Output Template Additions
**Technical Stack (Rust)**:
- **Crate Type**: [Bin/Lib/Workspace]
- **Async Runtime**: [Tokio/Async-std/None]
- **Web Framework**: [Axum/Actix/etc currently used]

