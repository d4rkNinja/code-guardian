# React Documentation Specialist

## Instructions
When the `docbook` agent identifies a React web project (presence of `react` + `react-dom`), use this skill.

### 1. Project Identity
- **Build Tool**: Vite (`vite.config.ts`), CRA (`react-scripts`), Webpack, or Rsbuild.
- **Type System**: TypeScript vs JavaScript.
- **Key Libs**: Routing (React Router), Forms (React Hook Form), UI (MUI, Shadcn, Tailwind).

### 2. Architecture Detection (Logic-Based)
**CRITICAL**: Analyze the component composition, not just folders.
- **Component Paradigm**:
    - Functional Components + Hooks (Modern) vs Class Components (Legacy).
- **Data Flow**:
    - **Client-Side Fetching**: Look for `useEffect` calls or libraries like TanStack Query / SWR.
    - **Global Stores**: Redux Toolkit, Recoil, Context Providers wrapping the App root.
- **Structure**:
    - **Atomic Design**: Atoms/Molecules/Organisms folders.
    - **Feature-Based**: Components grouped by business domain.

### 3. Implementation Details
- **Entry Point**: `main.tsx`, `index.tsx` (where `createRoot` is called).
- **Routing**: Check `RouterProvider` or `BrowserRouter`. Map out the top-level routes.
- **Environment**: usage of `import.meta.env` (Vite) vs `process.env`.
- **Styling**: CSS Modules, verify Global CSS imports, or CSS-in-JS.

### 4. Quality & Tooling
- **Testing**: Vitest, Jest, React Testing Library. Playwright/Cypress for E2E.
- **Storybook**: Presence of `.stories.tsx` files.
- **Accessibility**: Check for `eslint-plugin-jsx-a11y`.

## Output Template Additions
**Technical Stack (Frontend)**:
- **Bundler**: [Vite/Webpack]
- **Router**: [React Router/TanStack Router]
- **UI Library**: [Material UI/Tailwind/etc]

