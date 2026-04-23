# Starter Kits

Full, copyable `.claude/` directories plus a matching `CLAUDE.md` for common
stacks. Drop one into a fresh (or existing) project and Claude Code comes up
pre-configured with sensible permissions, formatters on write, secret blocking,
and a couple of opinionated skills that match the stack's idioms.

## Available kits

| Kit | Stack assumption | What you get |
|-----|------------------|--------------|
| [react](react/) | Vite or Next.js app, TypeScript, ESLint + Prettier | `CLAUDE.md`, `.claude/settings.json`, skills: `/component-new`, `/test-component`, shared hooks |
| [python](python/) | FastAPI or Django, `ruff` + `pytest`, `pyproject.toml` | `CLAUDE.md`, `.claude/settings.json`, skill: `/api-endpoint`, shared hooks |
| [go](go/)       | Go modules, standard `go test`, optional `golangci-lint` | `CLAUDE.md`, `.claude/settings.json`, skill: `/add-handler`, shared hooks |

Each kit is ~5 files. They're meant to be read in full before dropping in —
not every team wants every rule.

## Install into your project

From your project root:

```bash
# Copy the kit that matches your stack.
STARTER=react
cp -r path/to/claude-code-best-practices/starters/$STARTER/CLAUDE.md ./CLAUDE.md
cp -r path/to/claude-code-best-practices/starters/$STARTER/.claude   ./.claude
```

Then:

1. Read `CLAUDE.md` top to bottom and edit the sections marked `<!-- edit -->`.
2. Read `.claude/settings.json` and trim the permission allowlist to what
   your project actually uses.
3. Commit both files to the repo. The whole team picks up the same setup on
   next pull.

## Conventions used across all kits

- **Hooks live in `.claude/hooks/`**, not vendored from this repo. Each kit
  ships a copy of `block-secrets.sh` and `format-on-write.sh` so the starter
  is self-contained — no outside dependency.
- **Permissions are an allowlist**, not a deny list. If Claude asks for a
  tool that isn't allowed, you'll see a prompt. Add it deliberately rather
  than opening access wide.
- **`git push` is denied** in every kit. Uncomment if your team is comfortable.
- **No emojis** in the `CLAUDE.md` files — matches the repo-wide convention
  in [CONTRIBUTING.md](../CONTRIBUTING.md).
- **Skills are lean.** Two skills max per kit. Add more as you discover
  workflows your team repeats.

## Adding a new starter

1. Create `starters/<stack>/` with a `CLAUDE.md`, `.claude/settings.json`,
   `.claude/hooks/` (copy from `starters/react/.claude/hooks/`), and one or
   two `.claude/skills/<skill>/SKILL.md` files.
2. Keep the total to under ~300 lines across all files. The point of a
   starter is to be read, not to be exhaustive.
3. Add a row to the table above.
4. Run `bash tools/lint-claude-md.sh starters/<stack>/CLAUDE.md` — should
   pass with zero errors.

## See also

- [examples/](../examples/) — stack-specific `CLAUDE.md` templates (no `.claude/`)
- [guides/claude-md-guide.md](../guides/claude-md-guide.md) — how to write a `CLAUDE.md`
- [guides/hooks.md](../guides/hooks.md) — the hook events and exit-code contract
- [.claude/](../.claude/) — how this repo dogfoods the same pattern on itself
