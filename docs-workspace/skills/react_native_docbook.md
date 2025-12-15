# React Native Documentation Specialist

## Instructions
When the `docbook` agent identifies a React Native project (presence of `react-native` in `package.json`), use this skill.

### 1. Project Identity
- **Core Engine**:
    - **CLI vs Expo**: Check for `expo` in dependencies vs `react-native` only. Look for `app.json` (Expo) vs `android`/`ios` folders (CLI).
    - **Version**: React Native version.
- **Platform Support**: Android, iOS, Web (react-native-web), Windows/MacOS?

### 2. Architecture Detection (Component Analysis)
**CRITICAL**: Drill down into the component hierarchy.
- **Navigation Flow**:
    - Identify the Navigator (React Navigation, React Native Navigation).
    - Map the "Screens" vs "Components". Look for files registering screens.
- **State Management**:
    - Global: Redux (`Provider`), Zustand (`create`), Context API.
    - Local: Heavy use of `useState` inside screens.
- **Native Modules**:
    - Look for usage of `NativeModules` or bridging files (`.java`, `.m`, `.swift`) if specialized native code exists.

### 3. Implementation Details
- **Entry Point**: `index.js` (AppRegistry) or `App.tsx`.
- **Styling Strategy**: `StyleSheet.create`, Styled Components, or Tailwind (NativeWind).
- **Network Layer**: Axios, Fetch, TanStack Query? Where are API calls centralized?
- **Assets**: How are images/fonts handled? (local require vs remote).

### 4. Quality & Tooling
- **Testing**: Jest (snapshot testing), Detox (E2E), Maestro.
- **Linting**: ESLint, Prettier.
- **Types**: TypeScript usage (strictness in `tsconfig.json`).

## Output Template Additions
**Technical Stack (Mobile)**:
- **Framework**: React Native (CLI/Expo)
- **Navigation**: [Library Name]
- **State**: [Library Name]
- **Native Capabilities**: [List specific permissions used like Camera, Location based on `AndroidManifest` or `Info.plist`]

