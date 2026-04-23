# Example Skills

Drop-in skills for Claude Code. Each folder is a standalone skill you can copy into your project's `.claude/skills/` directory or into `~/.claude/skills/` for global use.

## Included

| Skill | What it does |
|-------|--------------|
| [changelog](changelog/SKILL.md) | Generate a `CHANGELOG.md` entry from commits since the last tag |
| [pr-describe](pr-describe/SKILL.md) | Write a PR title + body from the branch's commits and diff |
| [test-triage](test-triage/SKILL.md) | Classify failing tests as flaky vs. real, and propose a fix path |

## Install one

```bash
# Project-scoped
cp -r examples/skills/changelog .claude/skills/

# Or user-scoped
cp -r examples/skills/changelog ~/.claude/skills/
```

Then inside Claude Code:

```
/changelog
```

## Anatomy of a skill

```
changelog/
└── SKILL.md     # YAML frontmatter (name, description, allowed-tools) + instructions
```

The `description` field is how Claude decides when to invoke the skill — be specific about *when* it applies, not just *what* it does.

See the [Skills and Slash Commands](../../guides/skills-and-slash-commands.md) guide for authoring patterns.
