# Writing Effective CLAUDE.md Files

CLAUDE.md is a special Markdown file that gives Claude Code persistent context about your project. Think of it as a briefing document -- it tells Claude your conventions, tech stack, testing commands, and preferences so you don't have to repeat them every session.

## What is CLAUDE.md?

When Claude Code starts a session, it automatically reads any CLAUDE.md files it finds in your project. This context is injected into every conversation, helping Claude make decisions that align with your project's conventions from the start.

## Where to Place CLAUDE.md Files

Claude Code reads CLAUDE.md files from multiple locations, in order of priority:

| Location | Scope | Use Case |
|----------|-------|----------|
| `~/.claude/CLAUDE.md` | Global | Personal preferences that apply to all projects |
| `./CLAUDE.md` | Project root | Project-wide conventions shared with the team |
| `./src/CLAUDE.md` | Subdirectory | Module-specific context (e.g., frontend vs backend) |

All discovered CLAUDE.md files are merged together, with more specific files taking precedence.

### Global CLAUDE.md

Place personal preferences in `~/.claude/CLAUDE.md`:

```markdown
# My Preferences
- Always use TypeScript strict mode
- Prefer functional components in React
- Use pnpm as the package manager
```

### Project Root CLAUDE.md

This is the most common location. Commit it to your repo so the whole team benefits:

```markdown
# Project: Acme Dashboard

## Tech Stack
- Next.js 14 with App Router
- TypeScript (strict mode)
- Tailwind CSS
- Prisma ORM with PostgreSQL

## Commands
- `pnpm dev` -- Start development server
- `pnpm test` -- Run tests with Vitest
- `pnpm lint` -- ESLint + Prettier check

## Conventions
- Use named exports, not default exports
- Place API routes in `app/api/`
- Use Zod for all input validation
- All database changes require a migration: `pnpm prisma migrate dev`
```

### Nested CLAUDE.md

For monorepos or projects with distinct sections, place additional files in subdirectories:

```
repo/
  CLAUDE.md              # Shared project conventions
  packages/
    frontend/
      CLAUDE.md          # React-specific conventions
    backend/
      CLAUDE.md          # API-specific conventions
```

## What to Include

### Essential Sections

- **Tech stack**: Languages, frameworks, and major libraries
- **Commands**: How to build, test, lint, and deploy
- **Conventions**: Naming patterns, file organization, coding style
- **Architecture**: High-level overview of how the system is structured

### Helpful Additions

- **Common pitfalls**: Known gotchas or legacy patterns to avoid
- **Testing patterns**: How to write tests, what to mock, coverage expectations
- **Environment setup**: Required environment variables or services
- **PR workflow**: Branch naming, commit message format, review process

## Tips for Keeping CLAUDE.md Effective

- **Keep it concise**: Claude reads the entire file every session. Aim for under 200 lines. Link to detailed docs instead of duplicating them.
- **Use bullet points**: They are easier for Claude to parse than long paragraphs.
- **Be specific**: "Use `vitest` for tests" is better than "we have tests".
- **Update regularly**: As your project evolves, keep CLAUDE.md in sync. Stale instructions cause confusion.
- **Avoid obvious information**: Don't document things Claude can figure out by reading your code (e.g., "this is a JavaScript project" when there's a package.json).
- **Include commands verbatim**: Claude will run exactly what you write, so include copy-pasteable commands.

## Anti-patterns to Avoid

- Pasting your entire codebase structure (too verbose, changes frequently)
- Duplicating information already in your README or docs
- Including secrets or API keys (CLAUDE.md is often committed to version control)
- Writing essays instead of actionable bullet points

## Example Structure

A well-organized CLAUDE.md follows this pattern:

```markdown
# Project Name

Brief one-line description.

## Tech Stack
- (list key technologies)

## Commands
- `command` -- description

## Conventions
- (list coding standards)

## Architecture
- (brief system overview)

## Common Pitfalls
- (list known gotchas)
```

For complete real-world examples, see the [Examples](../README.md) section in the main README.

## See Also

- [Getting Started](getting-started.md) -- Initial setup and first run
- [Prompt Tips](prompt-tips.md) -- Writing effective instructions for Claude
- [Context Management](context-management.md) -- Managing conversation context
- [Common Mistakes](common-mistakes.md) -- Anti-patterns to avoid
- [Team Setup](team-setup.md) -- Sharing CLAUDE.md across a team
