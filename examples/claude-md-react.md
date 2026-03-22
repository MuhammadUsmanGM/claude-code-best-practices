# Example CLAUDE.md — React/TypeScript Project

This example shows a complete CLAUDE.md for a React application built with TypeScript, using Vite as the build tool, Vitest for testing, and ESLint/Prettier for code quality. It covers the conventions a team would want Claude Code to follow consistently.

## The CLAUDE.md File

```markdown
# Project: Acme Dashboard

React 19 + TypeScript 5.x single-page application. Vite build system.

## Commands

- `npm run dev` — start dev server (port 3000)
- `npm run build` — production build
- `npm run test` — run all tests with Vitest
- `npm run test -- --run src/components/Button.test.tsx` — run a single test file
- `npm run lint` — ESLint + Prettier check
- `npm run lint:fix` — auto-fix lint issues
- `npm run typecheck` — tsc --noEmit

Always run `npm run typecheck && npm run lint` before committing.

## Architecture

- `src/components/` — reusable UI components (Button, Modal, Table, etc.)
- `src/features/` — feature modules (auth, dashboard, settings), each with its own components, hooks, and API calls
- `src/hooks/` — shared custom hooks
- `src/api/` — API client and typed request/response definitions
- `src/types/` — shared TypeScript types and interfaces
- `src/utils/` — pure utility functions

## Component Conventions

- Functional components only — no class components
- Use named exports, not default exports
- Co-locate tests: `Button.tsx` → `Button.test.tsx` in the same directory
- Co-locate styles: `Button.tsx` → `Button.module.css` (CSS Modules)
- Props interface named `{Component}Props` — e.g., `ButtonProps`
- Destructure props in the function signature

```tsx
// Good
export function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return <button className={styles[variant]} onClick={onClick}>{label}</button>;
}
```

## State Management

- Local state: useState/useReducer
- Server state: TanStack Query (React Query) — never store API data in local state
- Global app state: Zustand stores in `src/stores/`
- No Redux — do not introduce Redux or Redux Toolkit

## Testing

- Use Vitest + React Testing Library
- Test behavior, not implementation — query by role, text, or test ID
- Every component should have at least a smoke test (renders without crashing)
- Mock API calls with MSW (Mock Service Worker), not jest.mock
- Place test utilities in `src/test/helpers.ts`

## TypeScript

- Strict mode enabled — do not use `any` unless absolutely necessary with a comment explaining why
- Prefer `interface` over `type` for object shapes
- Use discriminated unions for state machines and complex state
- API response types live in `src/api/types.ts`

## Git

- Conventional commits: feat:, fix:, chore:, docs:, test:
- Branch naming: feature/, fix/, chore/
- Always create a PR — never push directly to main

## Do NOT

- Do not use `any` without a justifying comment
- Do not add new dependencies without discussing first
- Do not use inline styles — use CSS Modules
- Do not use default exports
```

## Key Sections Explained

**Commands** — Lists exact commands so Claude can run tests, linting, and type checks without guessing. The single-test example is especially useful since the syntax varies across test runners.

**Architecture** — Tells Claude where things live so it navigates the codebase directly instead of searching.

**Component Conventions** — Ensures Claude generates components matching team style: named exports, co-located tests, CSS Modules, and the props naming pattern.

**State Management** — Prevents Claude from introducing Redux or misusing local state for server data. These are the kinds of architectural decisions Claude cannot infer on its own.

**Do NOT** — Explicit guardrails for things the team has agreed to avoid. Claude respects these consistently.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [Minimal Example](./claude-md-minimal.md) — a simpler starting point
- [Monorepo Example](./claude-md-monorepo.md) — for projects with multiple packages
