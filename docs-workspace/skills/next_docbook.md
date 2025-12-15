# Next.js Documentation Specialist

## Instructions
When the `docbook` agent identifies a Next.js project (presence of `next` dependency), use this skill.

### 1. Project Identity
- **Architecture Generation**:
    - **App Router**: Presence of `app/` directory (Next.js 13+).
    - **Pages Router**: Presence of `pages/` directory.
    - **Hybrid**: Both exist.
- **Config**: Check `next.config.js` for standalone mode, image domains, rewrites.

### 2. Architecture Detection (Logic-Based)
**CRITICAL**: Distinguish between Server and Client execution contexts.
- **Rendering Strategy**:
    - Look for `getServerSideProps` (SSR) vs `getStaticProps` (SSG) in `pages/`.
    - Look for `"use client"` directives in `app/`. (Default is Server Component).
- **API Routes**:
    - `pages/api/*` vs `app/api/**/route.ts` (Route Handlers).
- **Data Fetching**:
    - Direct DB calls in Server Components?
    - `fetch` with caching tags?

### 3. Implementation Details
- **Routing**: Middleware presence (`middleware.ts`). Dynamic routes (`[slug]`, `[...catchall]`).
- **Styling**: Tailwind (global.css), CSS Modules, or CSS-in-JS Registry.
- **Optimization**: Usage of `next/image`, `next/font`.

### 4. Quality & Tooling
- **Linting**: `next lint`.
- **Types**: `next-env.d.ts` presence.
- **Deployment target**: Vercel-specific config? Dockerfile?

## Output Template Additions
**Technical Stack (Next.js)**:
- **Router Type**: [App Router / Pages Router]
- **Rendering**: [Heavy SSR / Static / Hybrid]
- **Styling**: [Tailwind / Modules]

