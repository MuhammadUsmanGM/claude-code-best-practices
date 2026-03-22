# Example CLAUDE.md — Monorepo

This example shows how to structure CLAUDE.md files in a monorepo with multiple packages. Claude Code supports nested CLAUDE.md files — the root file provides global conventions while package-level files add specific instructions for each package.

## Repository Structure

```
acme-platform/
├── CLAUDE.md                    # Root — global conventions
├── packages/
│   ├── api/
│   │   ├── CLAUDE.md            # API-specific instructions
│   │   └── src/
│   ├── web/
│   │   ├── CLAUDE.md            # Web app-specific instructions
│   │   └── src/
│   ├── shared/
│   │   ├── CLAUDE.md            # Shared library instructions
│   │   └── src/
│   └── cli/
│       └── src/                 # No CLAUDE.md — inherits root only
└── infrastructure/
    └── terraform/
```

## Root CLAUDE.md

```markdown
# Acme Platform Monorepo

Turborepo monorepo. Node.js 20, pnpm workspaces.

## Commands (from repo root)

- `pnpm install` — install all dependencies
- `pnpm build` — build all packages (respects dependency order)
- `pnpm test` — run all tests across all packages
- `pnpm lint` — lint all packages
- `pnpm dev` — start all dev servers

### Per-package commands

- `pnpm --filter @acme/api test` — run tests for a single package
- `pnpm --filter @acme/web dev` — start dev server for a single package
- `pnpm --filter @acme/shared build` — build a single package

## Architecture

- `packages/api` — Express.js REST API (Node.js backend)
- `packages/web` — Next.js frontend application
- `packages/shared` — shared TypeScript types, utilities, and constants (imported by api and web)
- `packages/cli` — CLI tool for internal operations
- `infrastructure/` — Terraform IaC (not a Node package)

## Global Conventions

- TypeScript strict mode in all packages
- Named exports only — no default exports
- All packages use the shared ESLint and Prettier configs from the root
- Import from `@acme/shared` for shared types — never duplicate type definitions across packages
- Use workspace protocol for internal deps: `"@acme/shared": "workspace:*"`

## Git

- Conventional commits with scope: `feat(api):`, `fix(web):`, `chore(shared):`
- PR titles should include the affected package(s)
- Run `pnpm lint && pnpm typecheck` before committing

## Do NOT

- Do not install dependencies in the root unless they are truly shared tooling
- Do not import directly from another package's src/ — always use the package's public API
- Do not create circular dependencies between packages
```

## packages/api/CLAUDE.md

```markdown
# @acme/api

Express.js REST API. This CLAUDE.md supplements the root CLAUDE.md.

## Commands

- `pnpm --filter @acme/api test` — run API tests
- `pnpm --filter @acme/api dev` — start with hot reload (port 4000)
- `pnpm --filter @acme/api test -- --grep "auth"` — run subset of tests

## Structure

- `src/routes/` — route handlers grouped by resource
- `src/middleware/` — Express middleware (auth, validation, error handling)
- `src/services/` — business logic
- `src/db/` — Prisma schema and migrations

## Conventions

- All routes use the async error wrapper from `src/middleware/asyncHandler.ts`
- Validate request bodies with Zod schemas in `src/schemas/`
- Use Prisma for all database access — no raw SQL
- Database migrations: `pnpm --filter @acme/api prisma migrate dev`
```

## packages/web/CLAUDE.md

```markdown
# @acme/web

Next.js 14 frontend with App Router.

## Commands

- `pnpm --filter @acme/web dev` — start dev server (port 3000)
- `pnpm --filter @acme/web test` — run Vitest tests
- `pnpm --filter @acme/web storybook` — start Storybook

## Structure

- `src/app/` — Next.js App Router pages and layouts
- `src/components/` — reusable UI components
- `src/hooks/` — custom React hooks
- `src/lib/` — API client, utilities

## Conventions

- Use Server Components by default — add 'use client' only when needed
- Styles: Tailwind CSS utility classes, no CSS Modules
- Data fetching: Server Components for initial data, TanStack Query for client-side
- Images: always use next/image
```

## packages/shared/CLAUDE.md

```markdown
# @acme/shared

Shared types, utilities, and constants. Imported by api, web, and cli.

## Important

- This package is a dependency of all other packages — breaking changes here affect everything
- Run `pnpm build` after any changes (other packages import the built output)
- Run the full repo test suite after changes: `pnpm test` from the root

## Structure

- `src/types/` — shared TypeScript interfaces and type definitions
- `src/utils/` — pure utility functions (must have zero external dependencies)
- `src/constants/` — shared constants and enums

## Conventions

- Every export must be re-exported from `src/index.ts`
- No runtime dependencies — this package should only export types and pure functions
- 100% test coverage on utility functions
```

## How Nested CLAUDE.md Files Work

When Claude Code operates on a file, it loads:
1. The **root CLAUDE.md** — always loaded, provides global conventions
2. The **nearest CLAUDE.md** in the file's directory ancestry — provides package-specific overrides

For example, when editing `packages/api/src/routes/users.ts`, Claude sees both the root conventions (TypeScript strict, conventional commits) and the API-specific conventions (use Prisma, Zod validation, async error wrapper).

Packages without their own CLAUDE.md (like `cli/`) inherit only the root file's instructions.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — fundamentals of CLAUDE.md configuration
- [React Example](./claude-md-react.md) — detailed single-project example
- [Python Example](./claude-md-python.md) — non-JavaScript project example
- [Minimal Example](./claude-md-minimal.md) — starting with the essentials
