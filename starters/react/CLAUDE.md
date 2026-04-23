# CLAUDE.md

<!-- Starter kit for React + TypeScript projects (Vite or Next.js). Edit the
     sections marked <!-- edit --> to match your codebase. -->

## Project

<!-- edit --> One-paragraph description of what this app does and who uses it.

- Framework: <!-- edit --> Vite 5 / Next.js 15 App Router
- Language: TypeScript (strict mode)
- Styling: <!-- edit --> Tailwind / CSS modules / styled-components
- State: <!-- edit --> Zustand / React Query / Context
- Tests: Vitest + React Testing Library

## Commands

- `npm run dev` — start dev server
- `npm test` — run unit tests in watch mode
- `npm run test:ci` — run tests once, with coverage
- `npm run lint` — ESLint + type-check
- `npm run build` — production build

Always run `npm run lint` and `npm run test:ci` before opening a PR. CI blocks
on both.

## Architecture

- `src/components/` — reusable presentational components, no data fetching.
- `src/features/<feature>/` — feature slices: components + hooks + tests
  colocated. New features live here.
- `src/lib/` — framework-agnostic utilities. No React imports allowed.
- `src/api/` — thin client wrappers around fetch. Never call fetch from
  components directly.

## Testing

- One test file per component, next to the component. `Foo.tsx` → `Foo.test.tsx`.
- Use React Testing Library queries in this order of preference:
  `getByRole` > `getByLabelText` > `getByText` > `getByTestId`.
- Never `act()` manually — RTL handles it. If you reach for `act`, you're
  probably testing implementation instead of behavior.
- Mock at the network boundary (MSW handlers in `src/test/msw/`), never the
  component's hooks.

## Conventions

- Prefer server components / RSC where the framework supports it. Mark client
  components with `'use client'` at the top of the file.
- Props interfaces named `<ComponentName>Props`, exported alongside the
  component.
- No default exports except for pages/routes that the framework requires.
- Filenames: PascalCase for components, camelCase for everything else.

## Do NOT

- Add dependencies without asking. The `package.json` is audited.
- Use `any`. Use `unknown` and narrow, or define the type properly.
- Add `// eslint-disable-next-line` without a comment explaining the reason.
- Commit generated files from `dist/`, `.next/`, or `coverage/`.

## Available skills

- `/component-new` — scaffold a component + test + stories with consistent
  structure.
- `/test-component` — write tests for an existing component using the project's
  RTL conventions.

## See also

- [starters/README.md](../README.md) — how this kit was assembled and how to
  adapt it
- [../../guides/claude-md-guide.md](../../guides/claude-md-guide.md) — how to
  write a good CLAUDE.md
