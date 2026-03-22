# Example CLAUDE.md — Minimal

You do not need a long CLAUDE.md to get value from it. This minimal example covers the 80/20 essentials: the commands Claude needs, where things live, and a few key rules. Start here and expand as you discover things Claude gets wrong without guidance.

## The CLAUDE.md File

```markdown
# MyApp

Node.js/Express backend with PostgreSQL.

## Commands

- `npm test` — run tests (Jest)
- `npm test -- --testPathPattern=users` — run tests matching "users"
- `npm run lint` — ESLint check
- `npm run dev` — start dev server

Run `npm run lint && npm test` before committing.

## Structure

- `src/routes/` — API route handlers
- `src/models/` — database models (Sequelize)
- `src/middleware/` — Express middleware
- `tests/` — test files mirroring src/ structure

## Rules

- TypeScript strict mode — no `any`
- All API responses use the format: `{ data, error, status }`
- Use the existing logger (`src/utils/logger.ts`), not console.log
```

## Why This Works

This is only 20 lines, but it tells Claude everything it needs for most tasks:

**Commands** — Claude knows how to run tests (including a single test), lint, and start the server. The pre-commit instruction ensures Claude runs checks before committing.

**Structure** — Four lines that prevent Claude from searching the entire codebase. When asked to "add a new endpoint," it knows to look in `src/routes/`. When asked to "add a model," it goes to `src/models/`.

**Rules** — Three rules that would otherwise be violated regularly:
- No `any` prevents the most common TypeScript shortcut
- The response format ensures consistency across endpoints
- The logger rule prevents scattered console.log statements

## When to Add More

Expand your CLAUDE.md when you notice Claude:
- Using the wrong coding style repeatedly
- Putting files in the wrong directory
- Missing a convention that matters to your team
- Suggesting libraries or patterns you have decided against

Each time, add one or two lines to address the specific issue. A CLAUDE.md that grows organically from real problems is more useful than one written speculatively.

## See Also

- [CLAUDE.md Setup Guide](../guides/claude-md-guide.md) — comprehensive guide to CLAUDE.md configuration
- [React Example](./claude-md-react.md) — a more detailed CLAUDE.md for a React project
- [Python Example](./claude-md-python.md) — CLAUDE.md for a Python project
- [Monorepo Example](./claude-md-monorepo.md) — nested CLAUDE.md files for monorepos
