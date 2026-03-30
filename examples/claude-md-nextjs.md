# Example CLAUDE.md — Next.js/Prisma Project

This example shows a CLAUDE.md for a full-stack Next.js application using Prisma as the ORM, NextAuth for authentication, and Tailwind CSS for styling. It covers the conventions that keep Claude Code aligned with the App Router patterns and Prisma workflows.

## The CLAUDE.md File

```markdown
# Project: Acme SaaS

Next.js 15 (App Router) + TypeScript + Prisma + PostgreSQL. Deployed on Vercel.

## Commands

- `npm run dev` — start dev server (port 3000)
- `npm run build` — production build
- `npm run test` — run all tests with Vitest
- `npm run test -- --run src/lib/__tests__/billing.test.ts` — single test
- `npm run lint` — ESLint + Prettier check
- `npx prisma migrate dev` — apply pending migrations
- `npx prisma generate` — regenerate Prisma client after schema changes
- `npx prisma studio` — open database GUI

Always run `npx prisma generate` after changing `prisma/schema.prisma`.

## Architecture

- `app/` — Next.js App Router pages and layouts
  - `app/(auth)/` — login, signup, forgot-password (public routes)
  - `app/(dashboard)/` — authenticated routes with sidebar layout
  - `app/api/` — API route handlers
- `components/` — shared UI components (Button, Card, DataTable, etc.)
- `lib/` — server-side utilities (db client, auth config, email, billing)
- `prisma/` — schema and migrations
- `public/` — static assets

## Routing Conventions

- Use route groups `(groupName)` for shared layouts, not for URL segments
- Page components are `page.tsx`, layouts are `layout.tsx`
- Loading states: `loading.tsx`. Error boundaries: `error.tsx`
- Server Components by default — only add "use client" when you need interactivity
- Data fetching happens in Server Components, not in client-side useEffect

## Database (Prisma)

- Schema lives in `prisma/schema.prisma`
- Always create a migration for schema changes: `npx prisma migrate dev --name descriptive-name`
- Use `lib/db.ts` for the singleton Prisma client — never instantiate `new PrismaClient()` elsewhere
- Soft deletes: use `deletedAt DateTime?` pattern, never hard delete user data
- Relations: always include `@relation` annotations explicitly

## Authentication

- NextAuth v5 configured in `lib/auth.ts`
- Protected routes use `auth()` from next-auth in Server Components
- API routes check session with `auth()` — return 401 if missing
- Never trust client-provided user IDs — always derive from session

## Styling

- Tailwind CSS with custom design tokens in `tailwind.config.ts`
- Use `cn()` from `lib/utils.ts` for conditional class merging
- No inline styles, no CSS Modules — Tailwind only
- Component variants: use class-variance-authority (cva)

## Testing

- Vitest + React Testing Library for component tests
- Use `lib/test/helpers.ts` for test utilities (mock session, mock db)
- Database tests use a separate test database — never test against dev/prod
- Mock Prisma with `vitest-mock-extended` — do not hit the real database in unit tests

## Git

- Conventional commits: feat:, fix:, chore:, refactor:
- Always include the scope: `feat(billing): add usage-based pricing`
- Never commit `.env.local` — use `.env.example` as reference

## Do NOT

- Do not use the Pages Router — App Router only
- Do not use `getServerSideProps` or `getStaticProps` (Pages Router patterns)
- Do not call APIs from Server Components — query the database directly
- Do not add "use client" to components that do not need browser APIs
- Do not use `any` — define Prisma-generated types or custom interfaces
```

## Key Sections Explained

**Routing Conventions** — Next.js App Router has many implicit conventions. Making them explicit prevents Claude from mixing up Server/Client Components or using Pages Router patterns.

**Database (Prisma)** — The migration workflow and singleton client rule are critical. Without these, Claude might modify the schema without creating a migration, or create duplicate Prisma clients that exhaust connection pools.

**Authentication** — The "never trust client-provided user IDs" rule prevents a common security mistake where Claude passes a user ID from the request body instead of deriving it from the session.

**Do NOT** — These guardrails specifically prevent Claude from reaching for older Next.js patterns it may have learned from training data.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — how to structure your own CLAUDE.md
- [React Example](./claude-md-react.md) — for client-side React without Next.js
- [Python Example](./claude-md-python.md) — for backend-only projects
- [Monorepo Example](./claude-md-monorepo.md) — for multi-package setups
