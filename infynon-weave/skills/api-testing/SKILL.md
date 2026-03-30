---
name: weave
description: Help users build, run, and analyze API test flows with INFYNON Weave (`infynon weave`). Use when the user asks about API testing, integration testing, flow-based testing, testing API sequences, security probing endpoints, runtime inputs (OTP, 2FA, CAPTCHA), or when .infynon/api/ directory is detected. Covers node creation, flow building, prompt inputs, body editing, AI-assisted wiring, security probes, and TUI visualization. Always use this skill whenever the user mentions testing APIs, flows, weave, integration tests, OTP handling, or prompt inputs — even if they don't say "infynon weave" explicitly.
---

# INFYNON Weave — API Flow Testing

## Think of This as a New Language

INFYNON Weave is a **domain-specific language for API flow testing**. Like any programming language, it has precise syntax rules and you must use the exact commands — you cannot "write the source files by hand" any more than you would hand-edit compiled bytecode.

The language has three noun types:
- **node** — one HTTP request (the smallest unit)
- **flow** — a directed graph of nodes connected by edges
- **edge** — a directed connection that carries context variables between nodes

And a small set of verbs: `create`, `run`, `attach`, `detach`, `validate`, `import`, `export`, `list`, `get`, `remove`, `clone`, `assertion`, `prompt`, `ai`.

**Learn the syntax. Use only these commands. Never hand-write the files.**

---

## CRITICAL RULE — Commands Only, Never Write Files Directly

> **You must NEVER create, edit, or write `.infynon/` files manually** (no YAML, TOML, or JSON file creation).
> Every node, flow, edge, assertion, and prompt input must be created and modified **exclusively through `infynon weave` CLI commands**.
>
> **Why this matters:** The files follow a precise internal schema that the CLI owns and manages. Manually written files use a different structure that either fails to load silently or produces wrong behavior that is very hard to debug.
>
> **If a command fails:** Show the exact error output and stop. Do not attempt to fix it by writing files manually. Diagnose the command invocation instead.
>
> **If the user asks to "just create the file":** Explain that the command is the only correct path. Hand-written `.infynon/` files are not a valid alternative — they are a different format.
>
> This rule applies in ALL situations, no exceptions.

---

You are helping the user work with **INFYNON** (`infynon weave`) — an AI-driven, node-based API flow testing system built into the INFYNON CLI.

Instead of testing a single endpoint in isolation, INFYNON Weave models your backend as a **directed graph**:
- **Node** = one API call (method, path, headers, body, assertions, extractions)
- **Edge** = directed connection between two nodes, carrying context variables between them
- **Flow** = named graph of nodes + edges representing a complete test scenario
- **Context** = variables extracted from responses (e.g., `token`, `user_id`) and threaded forward through edges

---

## Core Concept — Flow Testing

```
[POST /auth/login] ──token──▶ [POST /cart/create] ──cart_id──▶ [POST /cart/checkout]
      ↑ extracts token                ↑ uses token                    ↑ uses token + cart_id
```

Every node automatically receives the variables it needs from the upstream context. You don't manually wire JSON — the AI infers which variables to carry based on variable names, URL structure, and HTTP method conventions.

---

## Prerequisites — Install INFYNON

```bash
infynon --version

# If not installed:
npm install -g infynon                                               # All platforms
cargo install --git https://github.com/d4rkNinja/infynon-cli        # From source
```

---

## Validate — Check Nodes and Flows

Run before testing to catch missing references, bad paths, broken flows:

```bash
infynon weave validate
```

**Checks performed:**
- Every node: method is valid, path starts with `/`, body is valid JSON, extractions formatted correctly
- Every flow: entry node exists in library, every edge node exists, no circular dependencies
- Returns exit code 1 if any **errors** found (warnings don't fail)

**Output:**
```
✔  api-v1-onboarding-branches    valid
⚠  my-incomplete-node            WARNING: no assertions defined
✘  broken-flow                   ERROR: entry node 'missing-node' not found

Summary: 7 nodes (6 valid, 1 warning) | 1 flow (0 valid, 1 error)
```

---

## OpenAPI / Swagger Import

Import an entire API spec in one command — generates nodes, extractions, assertions, and optionally a wired flow.

```bash
# Dry-run preview — nothing is saved
infynon weave import openapi.yaml --dry-run
infynon weave import swagger.json --dry-run

# Import all nodes
infynon weave import openapi.yaml

# Import and create a flow
infynon weave import openapi.yaml --flow "my-api-flow"

# Filter to specific path prefix only
infynon weave import openapi.yaml --prefix /api/v1

# Override base URL from spec
infynon weave import openapi.yaml --base-url http://staging.myapi.com
```

**What gets auto-generated per operation:**
- Node ID from `operationId` (camelCase → kebab-case) or `METHOD-path`
- `Content-Type: application/json` for POST/PUT/PATCH
- `Authorization: Bearer {$AUTH_TOKEN}` for non-auth endpoints (reads from env)
- Body template from `requestBody` schema — string fields become `{field_name}` placeholders
- Extractions from response schema (id, token, *_id, *_token, *_url fields)
- `status == 2xx` assertion + `body exists` assertion

Supports: OpenAPI 3.x (.yaml/.json) and Swagger 2.x, with `$ref` resolution.

---

## Env Variables in Nodes

Use `{$ENV_VAR_NAME}` in any field (path, headers, body) to pull from environment:

```bash
# In a node's Authorization header:
Authorization: Bearer {$AUTH_TOKEN}

# In a path:
/api/{$API_VERSION}/users

# In a body:
{"api_key": "{$MY_API_KEY}", "user_id": "{user_id}"}
```

**Resolution order:** `.env` file in `.infynon/.env` → process environment variables.

**Manage `.env` with CLI (do NOT hand-edit the file):**
```bash
infynon weave env set AUTH_TOKEN eyJhbGci...   # Add or update a variable
infynon weave env set BASE_URL http://staging.example.com
infynon weave env list                          # List all variables (sensitive values masked)
infynon weave env get AUTH_TOKEN                # Show single variable (masked)
infynon weave env get AUTH_TOKEN --reveal       # Show full value
infynon weave env delete OLD_TOKEN              # Remove a variable
```

**`.env` file format** (for reference — always use CLI to edit):
```env
AUTH_TOKEN=my-secret-token
API_KEY=abc123
BASE_URL=http://localhost:8001
# Comments are ignored
```

---

## Node Commands

Nodes are stored in `.infynon/api/nodes/` (format auto-detected from existing project files).

### Create a node

```bash
# Interactive wizard
infynon weave node create

# AI-generated from natural language description
infynon weave node create --ai "POST login with email and password, extracts token"
infynon weave node create --ai "GET user profile by user_id"
infynon weave node create --ai "DELETE product by product_id, returns 204"
infynon weave node create --ai "POST create cart, extracts cart_id"
```

### Manage nodes

```bash
infynon weave node list                        # List all nodes with method + path
infynon weave node get <id>                    # Show full node details
infynon weave node remove <id>                 # Delete a node
infynon weave node clone <id>                  # Duplicate a node (new id)
infynon weave node export <id>                 # Print node as curl or JSON
```

### Manage assertions per node

Each node has assertions that run after execution. Toggle them on/off without deleting.

```bash
infynon weave node assertion <node-id> list              # Show all assertions with index + status
infynon weave node assertion <node-id> enable <index>    # Enable assertion at index
infynon weave node assertion <node-id> disable <index>   # Disable assertion (skipped at runtime)
infynon weave node assertion <node-id> toggle <index>    # Flip enabled/disabled
infynon weave node assertion <node-id> add "status == 201"  # Add new assertion
infynon weave node assertion <node-id> add "body.id exists" --on-fail warn
infynon weave node assertion <node-id> remove <index>    # Remove assertion permanently
```

Disabled assertions are shown in validation output but silently skipped at runtime — useful for temporarily relaxing a check without losing it.

### Manage prompt inputs per node

Some endpoints need values only the user can supply at runtime (OTP codes, 2FA tokens, CAPTCHA responses, confirmation codes). Declare these as **prompt inputs** — the node pauses and asks the user before firing.

```bash
infynon weave node prompt <node-id> list                              # List all prompt inputs
infynon weave node prompt <node-id> add <var>                         # Add a prompt input
infynon weave node prompt <node-id> add otp_code --label "OTP Code"   # With custom label
infynon weave node prompt <node-id> add password --label "Admin Password" --secret   # Masked input
infynon weave node prompt <node-id> add session_id --default "test-session"           # With default
infynon weave node prompt <node-id> remove <index>                    # Remove a prompt input
```

**`--secret`** — masks user input with `*` characters. Use for passwords and tokens.
**`--default`** — pre-fills a value the user can accept by pressing Enter or override by typing.

The prompted value is injected as `{var_name}` in the request path, headers, and body — exactly like extracted variables:
```
# In node body after adding: node prompt verify-otp add otp_code --label "OTP Code"
{"otp": "{otp_code}", "session": "{session_id}"}

# In path:
/api/v1/verify/{otp_code}
```

**At runtime (CLI):**
```
  Node 'verify-otp' needs input:
  OTP Code: _          ← user types here
  Session ID [test]: _ ← shows default in brackets
```

**At runtime (TUI):** A modal overlay pauses the flow and shows labeled input fields. `Tab`/`↓` moves between fields, `Enter` submits the last field, `Esc` cancels.

### Run a single node

```bash
infynon weave node run <id>                                         # Run against default base URL
infynon weave node run <id> --base-url http://localhost:3000        # Specify server
infynon weave node run <id> --set token=abc123                      # Inject context variables
infynon weave node run <id> --set token=abc123 --set user_id=42
infynon weave node run <id> --prompt                                # Interactively ask for all unresolved {placeholders}
infynon weave node run <id> --set token=known --prompt              # Pre-fill known vars, prompt only for the rest
```

---

## Flow Commands

Flows are stored in `.infynon/api/flows/`. Run history is in `.infynon/api/runs/`.

### Create a flow

```bash
# Interactive — select nodes and wire them manually
infynon weave flow create "checkout-flow"

# AI-generated — describe what you want to test
infynon weave flow create "checkout-flow" --ai "test the full checkout: login, create cart, add items, checkout"
infynon weave flow create "auth-flow" --ai "register user, then login, then get profile"
```

### Manage flows

```bash
infynon weave flow list                        # List all flows with node count
infynon weave flow show <id>                   # ASCII graph visualization + edge list
infynon weave flow remove <id>                 # Delete a flow
infynon weave flow merge <id1> <id2>           # Merge two flows into one
```

### Run a flow

```bash
infynon weave flow run <id>                                   # Run with live step-by-step output
infynon weave flow run <id> --base-url http://localhost:3000  # Override base URL
infynon weave flow run <id> --output markdown                 # Save report to ./reports/
infynon weave flow run <id> --output pdf                      # Save PDF report
infynon weave flow run <id> --output both                     # Save both formats
```

**Live output format:**
```
  ✔  POST /auth/login               200    142ms
       ✔  status == 201
       ✔  body.token exists
  ✔  POST /cart/create              201     89ms
  ✘  POST /cart/checkout            422    201ms
       ✘  status == 200  (actual: 422)
```

---

## Attach / Detach — Manual Wiring

Connect nodes into a flow manually when you want precise control.

```bash
# Attach: after node A executes, node B runs next
infynon weave attach <from-id> <to-id>

# Carry specific variables on the edge (default: carry all)
infynon weave attach login-node cart-node --carry token
infynon weave attach login-node cart-node --carry token,user_id

# Conditional edge: only follow if assertion passes
infynon weave attach cart-node checkout-node --condition "status == 201"
infynon weave attach auth-node admin-panel --condition "body.role == admin"

# AI-inferred carry (AI decides what to carry based on variable names)
infynon weave attach login-node cart-node --ai

# Remove a connection
infynon weave detach <from-id> <to-id>
```

---

## AI Commands — Smart Flow Building

INFYNON AI uses heuristic pattern analysis — no external LLM required:
- Variable name matching (`token` → `Authorization: Bearer {token}`)
- URL structure analysis (`POST /users` creates → `GET /users/{user_id}` reads)
- HTTP method conventions (`POST` creates → `GET/DELETE` operate on the returned ID)
- Common auth patterns (login produces token → all others consume it)

### Suggest next nodes

```bash
infynon weave ai suggest <node-id>
# Shows ranked candidates with confidence score and reason
```

**Output example:**
```
  Suggestions for: login-node (POST /auth/login)
  ────────────────────────────────────────────────
  1. [95%]  cart-node      POST /cart/create     — consumes auth token from this node; related URL path
  2. [78%]  profile-node   GET /users/{user_id}  — provides variables needed; POST → GET progression
  3. [42%]  admin-node     GET /admin/users      — consumes auth token from this node
```

### AI attach — describe what to connect next

```bash
infynon weave ai attach <from-id> "the endpoint that creates the shopping cart"
infynon weave ai attach <from-id> "anything that needs the auth token" --flow-id <flow-id>
```

### AI complete — fill gaps in an existing flow

```bash
infynon weave ai complete <flow-id>
# Finds orphan nodes (not connected) and wires them into the flow automatically
```

### AI build-flow — build entire flow from scratch

```bash
infynon weave ai build-flow "full-checkout" --ai "login, create cart, add product, checkout, verify order"
# AI wires all matching nodes into a complete flow
```

### AI generate assertions and extractions

```bash
infynon weave ai assert <node-id>
# Generates smart defaults:
#   POST → status == 201, body.id exists, header.content-type contains application/json
#   DELETE → status == 204
#   GET → status == 200

infynon weave ai complete <flow-id>   # Also patches missing assertions on all nodes
```

### AI branch — add conditional branching

```bash
infynon weave ai branch <flow-id> <node-id>
infynon weave ai branch checkout-flow cart-node --condition "body.items > 0"
# Adds a conditional edge from node — only followed when condition is true
```

### AI explain — diagnose flow failures

```bash
infynon weave ai explain <flow-id>
# Human-readable diagnosis of the last failed run:
#   - Which step failed and why
#   - What assertion failed (actual vs expected)
#   - Context state at point of failure
#   - Latency warnings (>2000ms)
```

---

## Security Probes

Run automated security checks against your API after a successful flow run.

```bash
infynon weave ai probe <flow-id>
infynon weave ai probe <flow-id> --base-url http://localhost:3000
```

**Three probes run automatically:**

| Probe | What It Tests | Severity |
|-------|---------------|----------|
| **Auth Bypass** | Calls authenticated endpoints with no token — checks if 401/403 is returned | Critical |
| **Missing Rate Limit** | Sends 20 rapid requests to login/auth endpoints — checks for 429 response | High |
| **SQL Injection** | Injects SQLi payloads (`' OR '1'='1`) into body fields — checks for 500 errors | Critical |

**Output:**
```
  Security Probes — checkout-flow
  ────────────────────────────────────────────────────────────
  ✔  Auth Bypass      PASS  POST /cart/create correctly returned 401 without token
  ✘  Rate Limit       FAIL  POST /auth/login — no 429 returned after 20 rapid requests
                            Reproduce: for i in $(seq 1 20); do curl -X POST http://... ; done
  ✔  SQL Injection    PASS  POST /cart/checkout — no 500s on SQLi payloads
```

---

## Assertion Syntax

Assertions are evaluated against each node's response. Add them when creating nodes or via `infynon weave ai assert`.

```
status == 200          status != 404          status >= 200         status <= 299
body.field exists      body.field not exists
body.field == "value"  body.field != "value"
body.field > 0         body.field >= 1        body.field < 100      body.field <= 99
body.field contains "substr"
body.nested.path == "value"   # dot-notation for nested JSON
body.items.0.id exists        # array index access
header.content-type contains "application/json"
header.x-request-id exists
```

**On-fail actions:**
- `stop` — halt the entire flow on failure (default for critical assertions)
- `warn` — log failure but continue the flow

---

## Variable Extraction Syntax

Extracted variables are stored in the flow context and carried to downstream nodes.

```
from: "status"             → extracts HTTP status code
from: "body.token"         → extracts body.token field
from: "body.user.id"       → nested path
from: "body.items.0.id"    → first element of array
from: "header.x-session"   → response header
from: "body"               → entire response body as JSON
```

**In subsequent nodes, use `{var_name}` in paths, headers, or body:**
```
path: /users/{user_id}
headers: Authorization: Bearer {token}
body: {"cart_id": "{cart_id}", "quantity": 1}
```

---

## TUI — 10-Tab Dashboard

```bash
infynon weave tui               # Open TUI, last active flow
infynon weave tui <flow-id>     # Open TUI on a specific flow
```

| Key | Tab | What It Shows |
|-----|-----|---------------|
| `1` | Overview | All flows list with last run status + quick stats. `Enter`/`a` to run. |
| `2` | Flow Graph | Box-drawing node visualization with directed edges and sidebar info |
| `3` | Live Execution | Step-by-step run feed with assertion results per step |
| `4` | Latency Profiler | Bar chart sorted slowest → fastest, p95/avg/max per node |
| `5` | Security Probes | Auth bypass / rate limit / SQLi probe results |
| `6` | Coverage Map | Per-node coverage gauges (how many times run, pass rate) |
| `7` | State Inspector | Final context variables + schema drift comparison |
| `8` | Run Diff | Side-by-side comparison of two flow runs |
| `9` | Node Library | Searchable list of all nodes. `Enter`/`r` to run, `b` to edit body. |
| `0` | Config | Markdown/PDF output toggles, default base URL editor |

**Global TUI keys:**

| Key | Action |
|-----|--------|
| `1`–`9`, `0` | Switch tabs |
| `q` | Quit |
| `R` | Refresh data from disk |
| `/` | Open search (Node Library) |
| `?` | Help overlay |

**Overview (tab 1) keys:**

| Key | Action |
|-----|--------|
| `↑` / `↓` | Select a flow |
| `Enter` / `a` | Run the selected flow — auto-switches to Live Execution (tab 3) |

**Node Library (tab 9) keys:**

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate nodes |
| `Enter` / `r` | Run selected node in isolation |
| `b` | Open interactive body editor for the selected node |
| `/` | Search nodes by ID or path |

**Body Editor (opened with `b` in tab 9):**

The body editor is a full-screen inline JSON editor with line numbers and a block cursor:

| Key | Action |
|-----|--------|
| Any character | Insert at cursor |
| `Tab` | Insert 2 spaces |
| `Enter` | Insert newline (split line) |
| `Backspace` | Delete char before cursor; merges lines at start of line |
| `Delete` | Delete char at cursor; merges next line at end of line |
| `↑` / `↓` / `←` / `→` | Move cursor |
| `Home` / `End` | Move to start / end of line |
| `Ctrl+S` | Save to node file and close |
| `Esc` | Close without saving |

On save, valid JSON is compacted for storage and pretty-printed when reopened. Invalid JSON is saved as-is (flagged by `validate`).

**Prompt Input Modal (shown when a running node has `prompt_inputs`):**

When a flow or node run reaches a node with prompt inputs, execution pauses and this modal appears over tab 3:

| Key | Action |
|-----|--------|
| Any character | Type value into current field |
| `Backspace` | Delete last character |
| `Tab` / `↓` | Move to next field |
| `↑` | Move to previous field |
| `Enter` | Advance or submit (on last field) |
| `Esc` | Cancel — sends empty values |

Secret fields display `*` characters. Fields with defaults show them in dim text.

**Config (tab 0) keys:**

| Key | Action |
|-----|--------|
| `m` | Toggle markdown report output on/off |
| `p` | Toggle PDF report output on/off |
| `e` | Edit default base URL |

---

## Typical Workflows

### "I want to test my entire auth + checkout flow"
```bash
# 1. Create nodes for each step
infynon weave node create --ai "POST /auth/login with email and password, extracts token and user_id"
infynon weave node create --ai "POST /cart/create extracts cart_id"
infynon weave node create --ai "POST /cart/items add product_id and quantity"
infynon weave node create --ai "POST /cart/checkout"

# 2. Let AI build the flow
infynon weave flow create "checkout" --ai "login then create cart then add items then checkout"

# 3. Run it
infynon weave flow run checkout --base-url http://localhost:3000

# 4. Run security probes
infynon weave ai probe checkout --base-url http://localhost:3000
```

### "I want to test my API and see why it's failing"
```bash
infynon weave flow run <flow-id> --base-url http://localhost:3000
infynon weave ai explain <flow-id>
```

### "I want to add a new endpoint to an existing flow"
```bash
infynon weave node create --ai "GET /orders/{order_id} returns order details"
infynon weave ai attach <checkout-node-id> "the endpoint that retrieves the order after checkout"
# or
infynon weave ai complete <flow-id>    # AI finds and wires orphan nodes automatically
```

### "I want to check security of my API"
```bash
infynon weave flow run <flow-id> --base-url http://staging.myapi.com
infynon weave ai probe <flow-id> --base-url http://staging.myapi.com
```

---

## File Structure

```
.infynon/
└── api/
    ├── nodes/
    │   ├── login.toml           # Created by: infynon weave node create
    │   └── checkout.toml        # ⚠ Never write these by hand — use commands
    ├── flows/
    │   └── checkout-flow.toml   # Created by: infynon weave flow create
    └── runs/
        └── checkout-flow__1234567890.json   # Written automatically by flow run
```

> **Note:** Existing `.yaml` node/flow files are supported for loading (read-only compatibility), but new files created by commands are always `.toml`. Do not write `.yaml` files — use commands.

---

## Prompt Inputs — Runtime Interactive Values

Some nodes need values that only exist at test time (OTPs, 2FA codes, confirmation tokens). Declare them as prompt inputs on the node — the flow pauses and asks the user before the node fires.

```bash
# Add a prompt input
infynon weave node prompt <node-id> add <var-name>
infynon weave node prompt <node-id> add <var-name> --label "Human label"
infynon weave node prompt <node-id> add <var-name> --label "Password" --secret
infynon weave node prompt <node-id> add <var-name> --default "fallback-value"

# List prompt inputs on a node
infynon weave node prompt <node-id> list

# Remove a prompt input (use list to find the index)
infynon weave node prompt <node-id> remove <index>
```

The prompted `var-name` is injected into `{var-name}` placeholders in the node's path, headers, and body — no different from extracted variables. Chain them naturally:

```bash
# login node extracts session_id → carry it to verify-otp → user only types the OTP
infynon weave attach login verify-otp --carry session_id
infynon weave node prompt verify-otp add otp_code --label "OTP Code" --secret
```

**Full example — OTP verification flow:**
```bash
infynon weave node create --ai "POST /auth/verify-otp with otp_code and session_id"
infynon weave node prompt verify-otp add otp_code --label "OTP Code" --secret
infynon weave node prompt verify-otp add session_id --label "Session Token" --default ""
infynon weave attach login verify-otp --carry session_id
infynon weave flow run auth-flow
# → flow pauses at verify-otp, modal appears, user types OTP, flow continues
```

---

## Complete Command Reference

### node
```bash
infynon weave node create [--ai "description"]
infynon weave node list
infynon weave node get <id>
infynon weave node run <id> [--base-url URL] [--set KEY=VALUE ...] [--prompt]
infynon weave node clone <id> <new-id>
infynon weave node export <id> [--format curl|json] [--base-url URL]
infynon weave node remove <id>
infynon weave node assertion <id> list|enable|disable|toggle|add|remove
infynon weave node prompt <id> list|add|remove
```

### flow
```bash
infynon weave flow create <name> [--ai "description"]
infynon weave flow list
infynon weave flow show <id>
infynon weave flow run <id> [--base-url URL] [--set KEY=VALUE ...] [--output markdown|pdf|both]
infynon weave flow run-all [--base-url URL] [--set KEY=VALUE ...] [--output markdown|pdf|both]
infynon weave flow remove <id>
infynon weave flow merge <id1> <id2> --join-at <node-id> [--name NAME]
```

### graph
```bash
infynon weave attach <from> <to> [--carry VAR,...] [--condition EXPR] [--ai]
infynon weave detach <from> <to>
```

### import
```bash
infynon weave import <spec-file> [--flow NAME] [--base-url URL] [--prefix /path] [--dry-run]
```

### env
```bash
infynon weave env set <KEY> <VALUE>    # Add or update a variable in .infynon/.env
infynon weave env list                 # List all variables (sensitive values masked)
infynon weave env get <KEY>            # Show value (masked if sensitive)
infynon weave env get <KEY> --reveal   # Show full value
infynon weave env delete <KEY>         # Remove a variable
```

### validate
```bash
infynon weave validate
```

### ai
```bash
infynon weave ai suggest --after <node-id>
infynon weave ai attach --after <node-id> [--flow <flow-id>]
infynon weave ai complete <flow-id>
infynon weave ai probe <flow-id> [--base-url URL]
infynon weave ai build-flow --nodes ID,ID,... [--name NAME]
infynon weave ai explain <flow-id> [--run N]
infynon weave ai assert <node-id>
infynon weave ai branch <node-id>
```

### tui
```bash
infynon weave tui [<flow-id>]
```
