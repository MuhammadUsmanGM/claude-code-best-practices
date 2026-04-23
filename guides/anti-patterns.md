# Anti-Patterns Gallery

An annotated tour of CLAUDE.md files, hook configs, and prompts that look
reasonable, fail in practice, and almost never get caught by linters. Each
entry pairs the **bad** version with the **fixed** version and the one-line
reason it matters.

Use this as a review checklist — if you spot one of these in a PR, link
straight to it.

## CLAUDE.md anti-patterns

### AP-1: Vague instructions that Claude can't act on

**Bad**

```markdown
## Guidelines

- Write clean code.
- Follow best practices.
- Be careful with the database.
- Make sure things work.
```

**Fixed**

```markdown
## Guidelines

- Run `npm run lint` before committing; the CI gate rejects unformatted code.
- Prefer `async/await` over `.then()` chains — the codebase is fully migrated.
- Every migration must be reversible. Write the `down()` function even if
  trivial; the staging DB replays migrations backwards nightly.
- For any change under `src/billing/`, run `pytest tests/billing/ -x` before
  opening a PR.
```

**Why:** "Clean code" is not an instruction, it's a mood. Claude reads the
bad version and has no new information. The fixed version gives four concrete
actions and the *why* for each. The linter flags "write clean code" /
"follow best practices" / "be careful" — see `tools/lint-claude-md.sh`.

---

### AP-2: Empty or outline-only sections

**Bad**

```markdown
## Architecture

## Testing

## Deployment

## Gotchas
```

**Why:** Empty headings waste the context budget — they're tokens that say
nothing. Worse, they make the file look complete, which discourages future
contributors from filling them in.

**Fix:** delete the section until you have content for it. A 40-line file with
real content beats a 200-line file with four empty stubs.

---

### AP-3: Outdated model references

**Bad**

```markdown
## Model

This project targets claude-3-opus for hard tasks and claude-3-haiku for
boilerplate.
```

**Why:** Model IDs rotate. Pinning a retired model means Claude can't run the
instruction at all; pinning an old model means you miss capability
improvements. The linter catches retired IDs like `claude-2`, `claude-instant`,
and the `claude-3-*` family.

**Fix:** describe the *selection criterion*, not the model name. "Use the
current Sonnet for most work; switch to the current Opus for plan mode and
architecture reviews." See [Performance Tuning](performance-tuning.md).

---

### AP-4: Absolute paths that only exist on your laptop

**Bad**

```markdown
## Where things live

- The API runs from `/home/alex/work/shopco/api/`.
- Fixtures live in `/Users/alex/Desktop/test-data/`.
```

**Why:** Teammates cloning the repo will read a fictitious map. Claude may
generate commands that reference your home directory in PRs.

**Fix:** relative paths from the repo root. `src/api/` and `tests/fixtures/`
work for everyone. The linter warns on common absolute-path roots like
`/home/`, `/Users/`, `/var/`, `/opt/`, `/tmp/`.

---

### AP-5: Secrets baked into CLAUDE.md

**Bad** (illustrative only — real tokens look like this with ~40+ chars of
random data after the prefix)

```markdown
## Credentials

The staging API key is a real `sk-ant-…` value pasted here. Use it when
testing the `/generate` endpoint.
```

**Why:** CLAUDE.md is checked into git. The moment a real key lands on a
branch, it's leaked — rotating it is the only fix. The linter and the
`block-secrets` hook catch `sk-…`, `ghp_…`, `AKIA…`, Slack tokens, and
`password = "..."` patterns.

**Fix:** reference an env var and point to where the real value lives
(password manager, secret store). `Load the staging key from $SHOPCO_STAGING_KEY,
which is in 1Password under "ShopCo / staging".`

---

### AP-6: The 600-line monolith

**Bad:** a single CLAUDE.md at repo root covering API, web, mobile, infra,
ML pipelines, and docs — 600 lines, six H1s (yes, really), three
contradictory test commands.

**Why:** Claude reads the whole file every session. You pay for tokens you
don't need, and sections conflict when engineers update only their own.

**Fix:** one CLAUDE.md per package in a monorepo. Claude Code walks up from
`cwd` and concatenates; the root file holds only cross-cutting rules. See
[examples/claude-md-monorepo.md](../examples/claude-md-monorepo.md).

---

## Hook anti-patterns

### AP-7: A PreToolUse hook that calls Claude

**Bad**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          { "type": "command", "command": "claude -p 'review this write'" }
        ]
      }
    ]
  }
}
```

**Why:** Recursive Claude invocations from inside a tool-use event run up
token bills fast, block the user's main session, and can loop if the inner
Claude triggers its own hook. Hooks should be deterministic shell logic, not
another LLM call.

**Fix:** hooks do cheap, local checks (lint, grep, formatter). Reserve Claude
for the main loop. If you *really* want LLM review on writes, run it
asynchronously after the session ends via a `Stop` hook.

---

### AP-8: Silently-failing hooks

**Bad**

```bash
#!/usr/bin/env bash
# format-on-write.sh
prettier --write "$1" 2>/dev/null
```

**Why:** If `prettier` isn't installed, the write silently doesn't format.
You assume formatting is happening. Six months later, you discover half the
repo was never formatted. Also, no `set -euo pipefail`, no stdin handling
(hooks receive JSON on stdin, not positional args).

**Fix:** see `tools/hooks/format-on-write.sh` in this repo — it uses
`set -euo pipefail`, reads JSON from stdin, logs a warning to stderr when the
formatter fails, and exits 0 so it doesn't block writes.

---

### AP-9: Wrong exit codes

**Bad**

```bash
#!/usr/bin/env bash
# block-secrets.sh
if grep -q AKIA "$content"; then
  echo "secret detected"
  exit 1
fi
```

**Why:** Claude Code's hook contract: `0` = allow, `2` = block with stderr
shown to Claude, anything else = script error. Returning `1` looks like a
bug to Claude Code and may or may not block — behavior differs by hook event.

**Fix:** return `2` for blocks, write the reason to **stderr** (not stdout),
return `0` on allow. See [guides/hooks.md](hooks.md).

---

### AP-10: Matching on tool names you don't mean

**Bad**

```json
{ "matcher": "Bash", "hooks": ["…"] }
```

…applied to a rule you meant for `git commit` only. Now every `ls`, `cat`,
and `npm test` invocation pays the hook tax and may be blocked by it.

**Fix:** match as narrowly as possible. If you want to intercept `git commit`,
match `Bash` *and* inspect `tool_input.command` inside the hook; short-circuit
early for anything else. See `plugins/commit-helper/hooks/block-secret-commits.sh`.

---

## Prompt anti-patterns

### AP-11: "Refactor this"

**Bad**

> "Refactor the auth module."

**Why:** Claude has to guess the goal, the constraints, and what "better"
means. You'll get a plausible change that may not match your intent, and
you'll spend more time reviewing and redirecting than you would have
prompting precisely.

**Fix**

> "The auth module has three call sites calling `buildSessionToken()` with
> duplicated claim-assembly logic. Extract the shared logic into a single
> function in the same file. Don't change the public API. Keep the tests
> green."

The fix gives goal, scope, and a stop condition. Claude's first attempt
lands much closer to what you wanted.

---

### AP-12: Multi-step prompts as one blob

**Bad**

> "Read the codebase, figure out the test framework, add tests for every
> module under src/lib, then run them all and fix any failures, then commit,
> then open a PR."

**Why:** Claude will attempt it, but error recovery is brittle — one test
failure in module 4 cascades into lost context for modules 5–12. You can't
review incrementally.

**Fix:** use plan mode for the outline, then execute step by step. Or
decompose into distinct prompts: "add tests for `src/lib/foo.ts`"; review;
next module. See [guides/workflow-patterns.md](workflow-patterns.md).

---

### AP-13: Lying to Claude about state

**Bad**

> "The tests are all passing. Add a feature for X." *(…tests are in fact red.)*

**Why:** Claude trusts the premise. It may add a feature on top of a broken
baseline, mask the existing failure with a new assertion, or refuse to
investigate the regression you didn't mention.

**Fix:** state the real situation. "Tests T3 and T7 are failing on main; I
don't know why yet. Before adding feature X, diagnose those two." Honest
inputs get better outputs.

---

### AP-14: Asking for "production-ready" without criteria

**Bad**

> "Build me a production-ready REST API for notes."

**Why:** "Production-ready" means different things to different people
(authn? rate limits? observability? SLOs? tenancy?). Claude will pick a
reasonable slice and you'll discover it's not yours.

**Fix:** enumerate. "Build a REST API for notes with: JWT auth, Postgres
storage, OpenAPI spec, one integration test per endpoint, Dockerfile. No
rate limiting yet, no multi-tenancy." Now "done" has a definition.

---

## Contributing to this gallery

Spotted a new anti-pattern in the wild? Add it with the same shape:

1. **Bad** example (real enough to recognize, trimmed of noise).
2. **Fixed** example.
3. One-paragraph **Why**.

Keep entries short. The value is in the pattern, not the exposition.

## See Also

- [CLAUDE.md Guide](claude-md-guide.md) — the positive-space version of AP-1 through AP-6
- [Hooks](hooks.md) — exit-code contract and event matchers (AP-7 through AP-10)
- [Prompt Tips](prompt-tips.md) — prompting that avoids AP-11 through AP-14
- [Common Mistakes](common-mistakes.md) — broader list of pitfalls beyond these patterns
