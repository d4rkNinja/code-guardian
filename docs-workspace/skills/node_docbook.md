# Node.js Documentation Specialist

## Instructions
When the `docbook` agent identifies a Node.js project (presence of `package.json`), use this skill to extract specific technical details for the documentation.

### 1. Project Identity (`package.json` Analysis)
 You MUST read `package.json` to extract and document:
- **Core Framework**: (e.g., Express, NestJS, Fastify, Koa).
- **Key Dependencies**: List major libraries for Database (Mongoose, Sequelize), Auth (Passport, JWT), and Utilities.
- **Scripts**: Document available `npm run` commands and what they do (e.g., `dev`, `build`, `test`, `lint`).
- **Engines**: Node/NPM versions required.

### 2. Architecture & Pattern Detection (Logic-Based)
**CRITICAL**: Do not rely on standard folder names (like `models` or `controllers`) as they vary by team. Instead, **drill down** into the code:
- **Trace the Entry Point**: Start at the file defined in `package.json` > `main` (or the `start` script). Follow the `require()` or `import` statements to map the flow.
- **Identify Roles by Syntax**:
    - *Data Layer*: Search for database schema definitions (e.g., `new mongoose.Schema`, `Sequelize.define`, `TypeORM @Entity`).
    - *Logic Layer*: Look for classes or functions containing business rules, decoupled from HTTP `req/res`.
    - *Transport Layer*: Look for route definitions (`app.get`, `router.post`) and simple handlers processing requests.
- **Determine Pattern**:
    - If logic is mixed inside routes -> **Monolithic/Script**.
    - If logic is separated into specific classes/functions -> **Layered/MVC**.
    - If grouped by feature (e.g., a folder containing route, schema, and logic for 'Users') -> **Modular/Domain-Driven**.

### 3. Implementation Details to Document
- **Entry Point**: Identify main file (e.g., `index.js`, `server.ts`).
- **Configuration**: How is config handled? (dotenv, `config/` folder).
- **Database Connection**: Where and how is the DB connected? (File path to connection logic).
- **API Structure**: If REST, describe the base URL structure. If GraphQL, mention the schema location.

### 4. Quality & Tooling Check
- **Linting/Formatting**: Check for `.eslintrc`, `.prettierrc`.
- **Testing**: Check for `jest.config.js` or `mocha` setup.
- **Type Safety**: Check for `tsconfig.json` (TypeScript vs JavaScript).

## Output Template Additions for Node.js
When writing the **System Design** and **Implementation** sections of the main doc, insert these `node-specific` blocks:

**Technical Stack (Node.js Specific)**:
- **Runtime**: Node.js v[X]
- **Framework**: [Name]
- **Database Driver**: [Name]
- **Testing**: [Name]

**Key Scripts**:
| Command | Description |
| :--- | :--- |
| `npm start` | [Explanation] |
| `npm run dev` | [Explanation] |

**Directory Map**:
Explain the purpose of:
- `node_modules/`: Dependencies (Managed by NPM)
- `src/`: Source code
- [Other specific folders found]

