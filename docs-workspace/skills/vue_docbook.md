# Vue Documentation Specialist

## Instructions
When the `docbook` agent identifies a Vue project (presence of `.vue` files, `vue` dep), use this skill.

### 1. Project Identity
- **Framework**:
    - **Vue CLI/Vite**: look for `vite.config.js`.
    - **Nuxt**: Look for `nuxt.config.ts`.
- **Version**: Vue 2 (Options API dominant) vs Vue 3 (Composition API).

### 2. Architecture Detection
**CRITICAL**: Check Script Setup vs Options.
- **Coding Style**:
    - `<script setup>`: Modern Composition API.
    - `export default { data() ... }`: Options API.
- **State Management**:
    - **Pinia**: `defineStore`.
    - **Vuex**: `createStore` (Legacy).
- **Project Structure (Nuxt)**:
    - `pages/` (Auto-routing).
    - `components/` (Auto-import).
    - `server/` (Nitro server routes).

### 3. Implementation Details
- **Routing**: Vue Router (`createRouter`) vs File-system routing (Nuxt).
- **Styling**: Scoped CSS (`<style scoped>`), Tailwind, SCSS.
- **Props/Events**: Usage of `defineProps`, `defineEmits`.

### 4. Quality & Tooling
- **Testing**: Vitest, Vue Test Utils.
- **Types**: TypeScript (`lang="ts"` in script blocks).

## Output Template Additions
**Technical Stack (Vue)**:
- **Version**: [Vue 2/3]
- **API Style**: [Options/Composition]
- **Meta-Framework**: [Nuxt/None]

