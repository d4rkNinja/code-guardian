# Tech Stack Detection Reference & Master Guide

This document provides the canonical rules for identifying a project's technology stack. The **DocBook** agent must use these rules to select the most specific sub-skill available.

## 1. Detection Hierarchy (Priority Order)
**CRITICAL**: Always prioritize **Frameworks** over **Languages**.
*   *Example*: If a project has `package.json` (Node) AND `next` dependency (Next.js), you MUST use `next_docbook`. Do not stop at `node_docbook`.

**Priority Flow**:
1.  **Meta-Frameworks** (Next.js, Nuxt, React Native, NestJS)
2.  **Web Frameworks** (React, Vue, Laravel, Django, Spring Boot)
3.  **Language Runtime** (Node.js, Python, PHP, Java, etc.)

---

## 2. Detailed Stack Signatures

### 🟢 JavaScript / TypeScript Ecosystem
| Stack | Primary Marker | Secondary Checks (Validation) | Skill File |
| :--- | :--- | :--- | :--- |
| **Next.js** | `"next"` in `dependencies` | `app/` dir (App Router) or `pages/` dir | `next_docbook.md` |
| **NestJS** | `"@nestjs/core"` | `src/main.ts` containing `NestFactory` | `nest_docbook.md` |
| **React Native** | `"react-native"` | `android/` and `ios/` folders, or `app.json` (Expo) | `react_native_docbook.md` |
| **React** | `"react"` (without Next/Native) | `vite.config.*` or `src/App.tsx` | `react_docbook.md` |
| **Vue / Nuxt** | `"vue"` or `"nuxt"` | `.vue` files, `nuxt.config.ts` | `vue_docbook.md` |
| **Node.js** | `package.json` | `express`, `fastify` in deps, or simple scripts | `node_docbook.md` |

### 🔵 Python Ecosystem
| Stack | Primary Marker | Secondary Checks (Validation) | Skill File |
| :--- | :--- | :--- | :--- |
| **Django** | `django` in `requirements.txt` / `pyproject.toml` | `manage.py`, `settings.py` | `python_docbook.md` |
| **FastAPI** | `fastapi` | `app = FastAPI()` in code | `python_docbook.md` |
| **Flask** | `flask` | `app = Flask(__name__)` | `python_docbook.md` |
| **General Python**| `*.py` files | `setup.py`, `Pipfile` | `python_docbook.md` |

### 🟣 PHP Ecosystem
| Stack | Primary Marker | Secondary Checks (Validation) | Skill File |
| :--- | :--- | :--- | :--- |
| **Laravel** | `"laravel/framework"` in `composer.json` | `artisan` file in root | `php_docbook.md` |
| **Symfony** | `"symfony/framework-bundle"` | `bin/console` | `php_docbook.md` |
| **General PHP** | `composer.json` or `*.php` | `index.php` | `php_docbook.md` |

### 🟤 Systems & Compiled Languages
| Stack | Primary Marker | Secondary Checks (Validation) | Skill File |
| :--- | :--- | :--- | :--- |
| **Rust** | `Cargo.toml` | `src/main.rs` (Bin) or `src/lib.rs` (Lib) | `rust_docbook.md` |
| **Go** | `go.mod` | `func main()` pattern | `go_docbook.md` |
| **Java (Spring)**| `pom.xml` or `build.gradle` | `@SpringBootApplication` annotation | `java_docbook.md` |
| **.NET** | `*.sln` Solution file | `*.csproj` with `<TargetFramework>` | `dotnet_docbook.md` |

---

## 3. Ambiguity Resolution Rules
If a workspace contains multiple stacks (e.g., a Monorepo):
1.  **Identify the Root**: Is the root folder a specific stack, or does it contain `packages/`?
2.  **Separate Documentation**: If possible, treat each sub-folder as a separate documentation target (e.g., `docs/backend` using `python_docbook` and `docs/frontend` using `next_docbook`).
3.  **Hybrid Approach**: If strictly one document is needed, prioritize the **Backend/API** structure (System Design) and treat Frontend as the "Implementation/View" layer.
