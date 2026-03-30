# INFYNON API Testing — Workflow Examples

## Example 1: Full Auth + CRUD Flow

### Scenario
You have a REST API with: `POST /auth/login` → `POST /products` → `GET /products/{id}` → `DELETE /products/{id}`

### Step 1: Create nodes

```bash
infynon weave node create --ai "POST /auth/login with email and password, extracts token and user_id"
# → creates node id: auth-login

infynon weave node create --ai "POST /products creates a product with name and price, extracts product_id"
# → creates node id: create-product

infynon weave node create --ai "GET /products/{product_id} returns product details"
# → creates node id: get-product

infynon weave node create --ai "DELETE /products/{product_id} returns 204"
# → creates node id: delete-product
```

### Step 2: Build flow with AI

```bash
infynon weave flow create "product-lifecycle" --ai "login, create product, get product, then delete it"
# AI wires: auth-login → create-product → get-product → delete-product
# AI infers: carry token on all edges, carry product_id from create to get/delete
```

### Step 3: Run

```bash
infynon weave flow run product-lifecycle --base-url http://localhost:3000
```

**Expected output:**
```
  Running flow: product-lifecycle
  Base URL: http://localhost:3000
  ────────────────────────────────────────────────
  ✔  POST /auth/login                   200     143ms
       ✔  status == 200
       ✔  body.token exists
  ✔  POST /products                     201      89ms
       ✔  status == 201
       ✔  body.id exists
  ✔  GET /products/42                   200      55ms
       ✔  status == 200
  ✔  DELETE /products/42                204      61ms
       ✔  status == 204
  ────────────────────────────────────────────────
  ✔ PASSED  4/4 steps  •  total: 348ms
```

### Step 4: Security probes

```bash
infynon weave ai probe product-lifecycle --base-url http://localhost:3000
```

---

## Example 2: Multi-Service Flow with Conditional Branching

### Scenario
E-commerce checkout where premium users skip the payment step.

```bash
# Create nodes
infynon weave node create --ai "POST /auth/login extracts token and user_role"
infynon weave node create --ai "GET /cart/{cart_id} returns cart total and items"
infynon weave node create --ai "POST /payment/charge processes payment"
infynon weave node create --ai "POST /orders/create creates the order, extracts order_id"

# Build base flow
infynon weave flow create "checkout" --ai "login, get cart, create order"

# Add conditional payment branch: only run payment for non-premium users
infynon weave attach get-cart payment-charge --condition "body.user_role != premium"
infynon weave attach payment-charge create-order
```

---

## Example 3: Investigate a Failing Flow

### Scenario
Your checkout flow started failing after a backend change.

```bash
# Run the flow
infynon weave flow run checkout --base-url http://staging.api.com

# Output shows failure at step 3:
#   ✘  POST /cart/checkout   422   201ms
#        ✘  status == 200  (actual: 422)

# Ask AI to explain
infynon weave ai explain checkout
```

**AI explanation output:**
```
Flow 'checkout' failed at 1 step(s):

  Step: checkout-node POST http://staging.api.com/cart/checkout
  Status: 422
  Failed check: status == 200 (actual: 422)
  ⚠ Context at failure:
      token    = eyJhbGciOiJI...   (present ✓)
      cart_id  = cart_9f3a2        (present ✓)
      user_id  = 42                (present ✓)

  Likely cause: All required variables are present. The 422 suggests a
  validation error — the checkout endpoint may require an additional field
  (e.g., shipping_address) that isn't being sent.
```

---

## Example 4: Incremental Flow Building

Start with one node and grow the flow over time.

```bash
# Start with just login
infynon weave node create --ai "POST /auth/login extracts token"
infynon weave flow create "my-flow" --ai "login flow"

# A week later, add a new endpoint
infynon weave node create --ai "POST /notifications/send sends a push notification"

# Ask AI to wire it in
infynon weave ai complete my-flow
# AI detects the orphan node and suggests where to connect it

# Or be explicit
infynon weave ai attach login-node "the notification endpoint"
```

---

## Example 5: CI/CD Integration

Run API flows in CI pipelines.

```yaml
# .github/workflows/api-tests.yml
name: API Integration Tests

on: [push, pull_request]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    services:
      backend:
        image: myapp:latest
        ports: ["3000:3000"]

    steps:
      - uses: actions/checkout@v4

      - name: Install INFYNON
        run: npm install -g infynon

      - name: Run API flow tests
        run: |
          infynon weave flow run auth-flow --base-url http://localhost:3000
          infynon weave flow run checkout-flow --base-url http://localhost:3000
          infynon weave flow run product-lifecycle --base-url http://localhost:3000

      - name: Run security probes
        run: infynon weave ai probe checkout-flow --base-url http://localhost:3000
```

---

## Example 6: Node Library Management

Keep your node library clean and well-organized.

```bash
# See all nodes at a glance
infynon weave node list

# Output:
#   ID                    METHOD  PATH                      ASSERTIONS  EXTRACTIONS
#   ─────────────────────────────────────────────────────────────────────────────
#   auth-login            POST    /auth/login               3           2
#   create-cart           POST    /cart                     2           1
#   get-cart              GET     /cart/{cart_id}           2           0
#   checkout              POST    /cart/checkout            3           1

# Clone a node to test a variant
infynon weave node clone auth-login
# → creates auth-login-2, edit to test a different auth flow

# Export node for documentation or sharing
infynon weave node export auth-login
```

---

## TUI Workflow — Visual Flow Debugging

```bash
infynon weave tui --flow-id checkout-flow
```

1. **Press `2`** — Switch to Flow Graph view. See the node graph with arrows.
2. **Press `↓`** to navigate nodes. **Press `Enter`** to see node details (path, headers, assertions).
3. **Press `3`** — Switch to Live Execution. Run the flow from TUI with `R` then watch steps stream in.
4. **Press `4`** — Latency Profiler. See which nodes are slowest — identify bottlenecks.
5. **Press `5`** — Security Probes. See probe results after running `infynon weave ai probe`.
6. **Press `8`** — Run Diff. Compare two runs side-by-side to spot regressions.
