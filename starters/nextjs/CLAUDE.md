# CLAUDE.md

<!-- Starter kit for Next.js 15 (App Router) + TypeScript projects. Edit the
     sections marked <!-- edit --> to match your codebase. -->

## Project

<!-- edit --> One-paragraph description of what this app does and who uses it.

- Framework: Next.js 15 (App Router)
- Language: TypeScript (strict mode)
- Styling: <!-- edit --> Tailwind / CSS modules
- Data: <!-- edit --> Prisma + PostgreSQL / Drizzle / REST
- Auth: <!-- edit --> NextAuth v5 / Clerk / custom
- Tests: Vitest + React Testing Library; Playwright for E2E

## Commands

- `npm run dev` — start dev server on :3000
- `npm test` — run unit tests in watch mode
- `npm run test:ci` — run tests once, with coverage
- `npm run lint` — ESLint + type-check
- `npm run build` — production build
- `npm run e2e` — run Playwright E2E tests

Always run `npm run lint` and `npm run test:ci` before opening a PR. CI blocks
on both. After editing `prisma/schema.prisma`, run `npx prisma generate`.

## Architecture

- `app/` — App Router pages and layouts.
  - `app/(public)/` — unauthenticated routes (marketing, login).
  - `app/(app)/` — authenticated routes; share a sidebar layout.
  - `app/api/` — route handlers. Thin; delegate to `lib/`.
- `components/` — shared presentational components, no data fetching.
- `features/<feature>/` — feature slices: server actions, components,
  hooks, tests. New features live here.
- `lib/` — server-side utilities (db client, auth, email). Never import
  from `app/` or `components/`.

## Server vs client components

- Server Components by default. Add `'use client'` only when you need
  interactivity, browser APIs, or React hooks like `useState`.
- Data fetching happens in Server Components or server actions. Never in
  `useEffect` for initial loads.
- Pass serializable props from server to client. No functions, no class
  instances, no Dates without `.toISOString()`.

## Testing

- Unit/component tests next to the source. `Foo.tsx` → `Foo.test.tsx`.
- Use RTL queries in this order: `getByRole` > `getByLabelText` >
  `getByText` > `getByTestId`.
- Mock at the network boundary (MSW handlers in `src/test/msw/`), not
  the component's hooks.
- E2E specs in `e2e/`, one file per user-facing flow.

## Conventions

- Props interfaces named `<ComponentName>Props`, exported alongside the
  component.
- No default exports except for `page.tsx`, `layout.tsx`, and other files
  the framework requires.
- Filenames: PascalCase for components, kebab-case for routes, camelCase
  for utilities.
- Never trust client-provided user IDs — derive from the session on the
  server.

## Do NOT

- Add dependencies without asking. The `package.json` is audited.
- Use `any`. Use `unknown` and narrow, or define the type properly.
- Call `fetch` from client components for first-load data — use a Server
  Component or server action instead.
- Commit generated files from `.next/`, `coverage/`, or `playwright-report/`.

## See also

- [starters/README.md](../README.md) — how this kit was assembled and how
  to adapt it
- [../../examples/claude-md-nextjs.md](../../examples/claude-md-nextjs.md) —
  a fuller Next.js + Prisma example
- [../../guides/claude-md-guide.md](../../guides/claude-md-guide.md) — how
  to write a good CLAUDE.md
