# Audit Your Claude Setup

`tools/audit-claude-setup.sh` scores a project's Claude Code configuration out
of 100. It checks the four things that decide whether Claude Code behaves well
in a repo -- CLAUDE.md, settings, permissions, and hooks -- and tells you what
to fix first.

## Run it

```bash
bash tools/audit-claude-setup.sh /path/to/project
```

or, from the project root:

```bash
bash tools/audit-claude-setup.sh .
```

Add `--strict` to fail (exit 1) on any outright FAIL regardless of score --
useful as a CI gate on setup quality.

## What it checks

| Area | Checks | Points |
|------|--------|--------|
| CLAUDE.md | Present, has 3+ `##` sections, reasonable length | 35 |
| settings.json | Present, valid JSON, no embedded secrets | 25 |
| Permissions | Non-empty allowlist, `git push` denied | 25 |
| Hooks | Configured, referenced scripts exist on disk | 15 |

Every FAIL and WARN comes with the reason and the fix. The output ends with a
score and a one-line verdict:

```text
CLAUDE.md
  [PASS] CLAUDE.md present at project root
  [PASS] CLAUDE.md structure: 6 ## sections
  [PASS] CLAUDE.md length: 87 lines

.claude/settings.json
  [PASS] .claude/settings.json present
  [FAIL] settings.json is not valid JSON

Score: 47/100
Result: needs work -- start with the FAIL items
```

## Scoring

- **85-100** -- strong setup. Minor polish available.
- **60-84** -- workable. Close the WARN items.
- **Below 60** -- needs work. Start with the FAIL items.

The tool needs `jq` (or `python3`) for the JSON checks; without either it
degrades to a partial audit and says so.

## In CI

The script exits `1` on a score under 60, or on any FAIL with `--strict`:

```yaml
- name: Audit Claude setup
  run: bash tools/audit-claude-setup.sh . --strict
```

Keep the threshold honest: a repo that passes with score 60 has a CLAUDE.md
and a valid settings file, but not necessarily a good one. Treat the score as
a floor, not a target.

## See Also

- [CLAUDE.md Guide](../guides/claude-md-guide.md) -- what belongs in CLAUDE.md
- [Security Practices](../guides/security-practices.md) -- the settings this tool checks for
- [Hooks](../guides/hooks.md) -- wiring the hook scripts it verifies exist
- [Team Setup](../guides/team-setup.md) -- rolling a shared setup out across a team
