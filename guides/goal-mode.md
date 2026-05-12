# Goal Mode

`/goal` (added in Claude Code v2.1.139) sets a completion condition and lets Claude keep working across turns until that condition is met. Where plan mode reaches alignment *before* work, goal mode runs the loop *after* alignment -- you stop reviewing each turn and instead review the outcome.

## How it works

You give Claude a completion condition. Claude works in a loop: prompt, tool use, self-evaluation against the condition, next prompt. The loop stops when:

- The condition is met (Claude reports success).
- Claude reports the goal cannot be reached and explains why.
- You interrupt with `Esc` or `Ctrl-C`.
- The session hits its token or turn budget.

An overlay panel shows live elapsed time, turns spent, and tokens consumed so you can pull the plug if the cost is getting out of hand. Goal mode works in interactive sessions, in headless `-p` mode, and inside Remote Control.

```text
/goal All tests in tests/api/ pass and `npm run lint` exits 0.
```

That is the entire interface. Specificity is everything -- see "Writing good completion conditions" below.

## When to use it

Goal mode is the right tool when:

- **The success criterion is mechanical.** Tests pass, lint clean, a script exits 0, a file matches a schema. Anything you could check with a one-line shell command.
- **The path is uncertain but the destination is not.** You do not know which 3 of 12 files need to change; you know what "done" looks like.
- **You are willing to trade tokens for attention.** Goal mode runs unsupervised. That is its value and its cost.

## When NOT to use it

| Situation | Why goal mode hurts |
|-----------|---------------------|
| Subjective outcome ("make the UI nicer") | No measurable stop condition -- the loop never converges |
| One-shot edit you could do yourself in 30 seconds | Loop overhead exceeds the work |
| Architectural decisions | Use plan mode; you need a human at each fork |
| First time touching a codebase | Claude will thrash without your domain context |
| Anywhere a wrong action is hard to undo | Each turn can call destructive tools without re-prompting you |

For architectural or design work, use plan mode. For everything between "one turn" and "open-ended exploration," goal mode is the new middle.

## Goal mode vs plan mode vs manual loop

| Approach | Human in the loop | Best for |
|----------|-------------------|----------|
| **Plan mode** | Before work starts | Designing the approach, scoping changes, getting alignment |
| **Manual loop** | Every turn | Learning a codebase, debugging unfamiliar bugs, work where context shifts the plan |
| **Goal mode** | Only at the end | Mechanical convergence toward a checkable outcome |

A common pattern: plan mode → approved plan → `/goal <plan's acceptance criteria>`. Plan mode commits the strategy; goal mode executes it without supervision.

## Writing good completion conditions

The single biggest determinant of cost and quality is the condition itself. A vague condition turns goal mode into an expensive `while true`.

| Bad condition | Better condition | Why |
|---------------|------------------|-----|
| "Fix all the bugs" | "`npm test` exits 0 and no `TODO` comments remain in `src/auth/`" | Mechanical, checkable, scoped |
| "Improve performance" | "The `/api/search` p95 in `bench/results.json` is under 200ms" | Has a number and a file Claude can re-read |
| "Make the tests pass" | "`pytest tests/billing/` exits 0 with `--strict-markers`" | Names the command and the directory |
| "Finish the migration" | "All files in `src/api/` import from `fetch` not `axios`, and `grep -r axios src/` returns nothing" | Two grep-checkable invariants |

Rules of thumb:

- **Name the command.** "Tests pass" is ambiguous; `npm test`, `pytest -q`, `cargo test --workspace` are not.
- **Name the scope.** "All tests" usually means "all the tests I care about right now" -- say so.
- **Add an invariant.** A second clause ("and no new TODOs") prevents Claude from satisfying the first by gaming it.
- **Make it falsifiable in one tool call.** If Claude has to run six commands to verify success, the loop gets slow and the failure modes multiply.

## Cost implications

Goal mode amplifies whatever your per-turn cost already is. A session burning 5K tokens per turn for 4 turns becomes 5K × 12 turns when the loop runs longer than expected. Three levers:

1. **Use Sonnet 4.6 unless you have a reason not to.** Opus 4.7 in a 30-turn loop adds up fast. See [Performance Tuning](performance-tuning.md) for model selection.
2. **Watch the overlay.** If turns and tokens are climbing without visible progress, interrupt. The loop will not get unstuck by itself.
3. **Bound the goal.** `/goal` is not `/wishlist`. The first version of the condition should be the smallest goal you can ship; expand only if it converges quickly.

The overlay shows tokens in real time so you can set personal stop-loss rules ("kill it past 100K tokens, regardless of progress"). Build the habit.

## Interactive, headless, and Remote Control

Goal mode behaves the same in all three modes, with one difference per mode:

| Mode | Difference |
|------|-----------|
| **Interactive** (`claude` REPL) | You see the live overlay; `Esc` interrupts |
| **Headless** (`claude -p "..."`) | No overlay; the loop runs to completion or failure. Best for CI and scripts. Set a wall-clock timeout outside Claude |
| **Remote Control** | Overlay is rendered in the remote UI; interrupt via the same control surface |

Headless goal mode is the most powerful and the most dangerous. A misconfigured CI job that runs `/goal` with a vague condition will burn through a budget overnight. Always pair headless `/goal` with a `timeout` wrapper and a token cap in your `claude` invocation.

## A worked example

```text
> /goal `bash tools/lint-claude-md.sh examples/claude-md-rust.md` exits 0,
        the file is between 100 and 180 lines, and it contains a "See Also"
        section linking to at least three sibling guides.
```

Three checkable clauses. Claude can run the linter, count lines, and grep for the section. The loop converges in a handful of turns and stops cleanly. Compare that with `/goal Make claude-md-rust.md production-ready`, which has no falsifiable end state and will burn tokens until you interrupt.

## See Also

- [Workflow Patterns](workflow-patterns.md) -- Manual workflows that goal mode replaces
- [Permission Modes](permission-modes.md) -- Plan mode vs goal mode, and how permissions interact with long-running loops
- [Cost Management](cost-management.md) -- Budgeting and watching token spend
- [Agent View](agent-view.md) -- Find and inspect long-running `/goal` sessions
- [CI and Automation](ci-and-automation.md) -- Headless `-p` patterns for goal mode in pipelines
