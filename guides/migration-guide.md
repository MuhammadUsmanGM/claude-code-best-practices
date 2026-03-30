# Migration Guide

Claude Code can help you migrate projects between frameworks, languages, APIs, and dependency versions. Migrations are complex, multi-file tasks where Claude's ability to read and transform entire codebases is especially valuable.

## Planning a Migration

Start by telling Claude the scope and constraints:

```bash
claude "I want to migrate this Express.js API to Fastify. There are 24 route files in src/routes/. Keep the same endpoint paths and response formats. Don't change the database layer."
```

For large migrations, break the work into phases:

```bash
claude "Plan a migration from JavaScript to TypeScript for this project. List the files in dependency order -- which files should be migrated first so that later files can import typed modules?"
```

## Framework Migrations

### Frontend Framework Changes

```bash
# React class components to functional components with hooks
claude "Convert src/components/Dashboard.tsx from a class component to a functional component with hooks. Keep the same props interface and behavior."

# Vue 2 to Vue 3
claude "Migrate this component from Vue 2 Options API to Vue 3 Composition API. Use script setup syntax."

# CSS-in-JS to Tailwind
claude "Convert the styled-components in src/components/Card.tsx to Tailwind CSS classes. Match the existing visual design exactly."
```

### Backend Framework Changes

```bash
# Express to Fastify
claude "Migrate this Express route to Fastify. Convert the middleware pattern to Fastify hooks and use the schema-based validation instead of express-validator."

# Flask to FastAPI
claude "Convert this Flask blueprint to a FastAPI router. Add Pydantic models for request/response validation based on the existing docstrings."
```

## Language Migrations

Claude can translate between languages while preserving logic and structure:

```bash
# JavaScript to TypeScript
claude "Add TypeScript types to src/utils/helpers.js. Rename to .ts. Infer types from usage patterns in the codebase. Use strict mode."

# Python 2 to Python 3
claude "Migrate this file to Python 3. Handle print statements, unicode strings, dict.keys() iteration, and exception syntax."

# REST to GraphQL
claude "Generate a GraphQL schema and resolvers based on the existing REST endpoints in src/routes/. Keep the same data shapes."
```

## Dependency Upgrades

### Major Version Bumps

```bash
claude "Upgrade React from v17 to v18. Update the root render call, handle any deprecated API usage, and check for breaking changes in our components."

claude "Migrate from Webpack 4 to Webpack 5. Update the config, handle any removed plugins, and fix module federation if used."
```

### Replacing Dependencies

```bash
claude "Replace moment.js with date-fns throughout the project. Update all imports and function calls to use the date-fns equivalents."

claude "Replace request (deprecated) with node-fetch in all files. Handle the callback-to-promise conversion."
```

## Database Migrations

```bash
# ORM migration
claude "Migrate from Sequelize to Prisma. Generate a Prisma schema from the existing Sequelize models and update all queries."

# Schema changes
claude "Add a soft-delete pattern to all models. Add a deleted_at column, update all queries to filter soft-deleted records, and add a restore method."
```

## Migration Strategies

### File-by-File

Best for framework migrations where each file can be converted independently:

```bash
claude "Migrate src/components/Header.tsx from class to functional component. Then do the same for Footer.tsx and Sidebar.tsx."
```

### Strangler Pattern

Run old and new code side by side:

```bash
claude "Set up a routing layer that sends /api/v2/* requests to the new Fastify server and everything else to the old Express server. We'll migrate routes one at a time."
```

### Big Bang

For smaller projects, migrate everything at once:

```bash
claude "Convert this entire project from JavaScript to TypeScript. Start with the leaf modules (no internal imports) and work up to the entry point."
```

## Verifying Migrations

Always verify that the migration preserves behavior:

```bash
# Run existing tests
claude "Run the full test suite after the migration and fix any failures."

# Compare outputs
claude "Write a script that hits every API endpoint and compares responses between the old and new implementations."

# Check for regressions
claude "Review the migrated code for any behavioral differences from the original. List anything that changed beyond syntax."
```

## Tips for Large Migrations

- **Migrate in small PRs** rather than one massive changeset. Ask Claude to migrate one module or feature at a time.
- **Keep tests green.** Run tests after each batch of changes. If tests break, fix them before continuing.
- **Use CLAUDE.md** to document migration rules so Claude stays consistent across sessions:

```markdown
## Migration Rules
- Use functional components with hooks, never class components
- Replace `any` types with proper interfaces
- Use named exports, not default exports
- Keep existing test files and update assertions as needed
```

- **Start a fresh conversation** for each migration batch to avoid context pollution from previous files.

## See Also

- [Workflow Patterns](workflow-patterns.md) -- General refactoring workflows
- [Context Management](context-management.md) -- Managing long migration sessions
- [CLAUDE.md Guide](claude-md-guide.md) -- Documenting migration rules for consistency
- [Testing Workflows](testing-workflows.md) -- Verifying migrations with tests
