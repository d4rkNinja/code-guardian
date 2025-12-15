# PHP Documentation Specialist

## Instructions
When the `docbook` agent identifies a PHP project (presence of `composer.json` or `.php` files), use this skill.

### 1. Project Identity (Dependency Analysis)
- **Check `composer.json`**:
    - **Framework**: Identify Laravel (`laravel/framework`), Symfony (`symfony/*`), or CMS (WordPress roots often lack composer, look for `wp-settings.php`).
    - **PHP Version**: Extract `require.php` version.
    - **Dependencies**: Key libs for DB (Doctrine, Eloquent), Logging (Monolog), Testing (PHPUnit).

### 2. Architecture Detection (Logic-Based)
**CRITICAL**: Do not assume standard folder structures. Drill into the code:
- **Trace Execution**:
    - Web Entry: specific `index.php` often leads to a kernel or bootstrapper.
    - CLI Entry: Look for console runners (e.g., `artisan`, `bin/console`).
- **Identify Pattern**:
    - **MVC Frameworks**: Look for Classes extending `Controller` or defining Routes (e.g., `Route::get` or `#[Route]`).
    - **CMS/Legacy**: Look for procedural code, extensive `include`/`require` of headers/footers, and hook systems (`add_action`).
    - **DDD/Hexagonal**: Look for strict namespaces separating `Domain`, `Application`, and `Infrastructure`.

### 3. Implementation Details
- **Configuration**: How is env loaded? (`.env`, `config.php`, constants).
- **Database**:
    - Look for connection logic (PDO, mysqli) or ORM configurations.
    - Identify migration folders (timestamped files with SQL or Schema builder code).
- **Autoloading**: Check `psr-4` mappings in `composer.json` vs custom `spl_autoload_register`.

### 4. Quality & Tooling
- **Static Analysis**: Look for `phpstan.neon`, `psalm.xml`.
- **Formatting**: `phpcs.xml` (CodeSniffer), `.php-cs-fixer.php`.
- **Testing**: `phpunit.xml`, `tests/` folder (Pest or PHPUnit).

## Output Template Additions
**Technical Stack (PHP)**:
- **Engine**: PHP v[X]
- **Framework**: [Name]
- **Web Server**: [Apache/Nginx assumptions based on config files]

