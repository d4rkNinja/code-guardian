---
name: weave
description: Help users build, run, and analyze API test flows with INFYNON Weave (`infynon weave`). Use when the user asks about API testing, integration testing, flow-based testing, testing API sequences, security probing endpoints, or when .infynon/api/ directory is detected. Covers node creation, flow building, AI-assisted wiring, security probes, and TUI visualization. Always use this skill whenever the user mentions testing APIs, flows, weave, or integration tests — even if they don't say "infynon weave" explicitly.
---

# INFYNON Weave — API Flow Testing

## CRITICAL RULE — Commands Only, Never Write Files Directly

> **You must NEVER create, edit, or write `.infynon/` files manually** (no YAML, TOML, or JSON file creation).
> Every node, flow, edge, and assertion must be created and modified **exclusively through `infynon weave` CLI commands**.
>
> **Why this matters:** The files have a precise schema that the CLI manages. Manually written files use a different format and will either fail to load or produce unexpected behavior.
>
> **If a command fails:** Report the exact error to the user and stop. Do not attempt to fix it by writing files manually. Debug the command invocation instead.
>
> This applies in all situations — even if the user asks you to "just create the file", explain that the command is the only safe path and run the command instead.

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

**Resolution order:** `.env` file in current directory → process environment variables.

**`.env` file format:**
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
infynon weave node export <id>                 # Print node as JSON
```

### Run a single node

```bash
infynon weave node run <id>                                   # Run against default base URL
infynon weave node run <id> --base-url http://localhost:3000  # Specify server
infynon weave node run <id> --set token=abc123                # Inject context variables
infynon weave node run <id> --set token=abc123 --set user_id=42
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

## TUI — 9-View Dashboard

```bash
infynon weave tui                    # Open TUI, last active flow
infynon weave tui --flow-id <id>     # Open TUI on specific flow
```

| Key | View | What It Shows |
|-----|------|---------------|
| 1 | Overview | All flows list with last run status + quick stats |
| 2 | Flow Graph | Box-drawing node visualization with directed edges, sidebar info |
| 3 | Live Execution | Step-by-step feed with assertion results per step |
| 4 | Latency Profiler | Bar chart sorted slowest → fastest, p95/avg/max per node |
| 5 | Security Probes | Auth bypass / rate limit / SQLi probe results |
| 6 | Coverage Map | Per-node coverage gauges (how many times run, pass rate) |
| 7 | State Inspector | Final context variables + schema drift comparison |
| 8 | Run Diff | Side-by-side comparison of two flow runs |
| 9 | Node Library | Searchable list of all nodes with method colors |

**Global TUI keys:**
- `[` / `]` — Switch between flows
- `R` — Refresh data from disk
- `/` — Search/filter (Node Library)
- `?` — Help overlay
- `q` — Quit

**Overview view keys (view 1):**
- `↑` / `↓` — Select a flow
- `Enter` or `a` — Run selected flow (switches to Live Execution automatically)
- Real-time results appear in view 3 (Live) as steps complete

**Flow Graph view keys:**
- `↑` / `↓` / `←` / `→` — Navigate nodes
- `Enter` — Show node detail panel
- `a` — Start attach mode (select a target node to wire)
- `Esc` — Cancel attach / close panel

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

For workflow examples, see [examples/workflows.md](examples/workflows.md).
