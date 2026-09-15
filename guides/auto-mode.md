# Auto Mode

Auto mode (research preview, March 2026; default for Pro, Max, and Team plans since August 2026) replaces the approve-everything loop with a background safety classifier. Instead of prompting you for each edit or command, Claude Code decides per action: clearly safe work proceeds on its own, everything else still asks you.

## How it differs from the modes you know

| Mode | Who approves routine actions | Safety net |
|------|------------------------------|------------|
| Default | You, every time | None needed |
| Allowlisted tools | Pre-approved patterns run; rest prompts | Your allowlist |
| Auto mode | The safety classifier | Sandboxing + classifier, still prompts for risky work |
| `--dangerously-skip-permissions` | Nobody | None -- you are the safety net |

Auto mode is not a rebrand of bypass permissions. Bypass removes the gate; auto mode adds a reviewer that never gets tired. The residual prompt traffic drops by an order of magnitude on ordinary feature work, but destructive commands, unknown network hosts, and ambiguous actions still stop for you.

## What the classifier actually does

Each candidate action -- a Bash command, an edit, a subagent hand-back -- is evaluated against your permission rules plus a trained safety model. Three outcomes:

- **Allow** -- the action runs without a prompt.
- **Ask** -- you get the normal permission prompt.
- **Deny** -- the action is refused with the classifier's reason.

Sandboxing makes the allow decision cheap to trust. Commands run in a restricted environment where filesystem writes outside the working tree and network access outside an allowlist fail on their own, so a mis-classified command cannot do the damage it would do unsandboxed.

### Per-command network domains

v2.1.271 added `allowed_domains` per command for Bash, PowerShell, and Monitor under auto mode with sandboxing. The hosts a command needs are reviewed with that command and opened for it alone; other hosts are refused. This closes the older hole where a one-time broad network grant leaked to every later command in the session.

## Enabling and controlling it

Cycle modes in a session with `Shift+Tab`; auto mode appears as its own stop in the cycle. To set it for future sessions:

```bash
claude config set --global preferredPermissionMode auto
```

To keep auto mode but re-prompt for a class of actions, add explicit `ask` rules -- explicit rules beat the classifier:

```json
{
  "permissions": {
    "ask": [
      "Bash(git push:*)",
      "Bash(terraform:*)",
      "WebFetch"
    ]
  }
}
```

To leave auto mode for a session, `Shift+Tab` back to manual (default). Organization policy can disable auto mode entirely, in which case the setting is hidden and sessions stay in default mode.

Quick reference:

| Goal | How |
|------|-----|
| Try auto mode for one session | `Shift+Tab` until auto mode is selected |
| Keep auto mode across sessions | `claude config set --global preferredPermissionMode auto` |
| Always prompt for a command class | `permissions.ask` rule in settings |
| Always allow a command class | `permissions.allow` rule in settings |
| Turn it off for good | `claude config set --global preferredPermissionMode default` |

## Adjusting the behavior, not just the mode

### Inline `!` commands

Auto mode changed how inline shell snippets in skills and slash commands are judged: they follow default-mode permission rules instead of the classifier. A command no rule decides runs as a reviewed tool call. If you write skills, this matters -- your `!` prefixed setup commands will prompt unless they match an allow rule.

### Subagent hand-backs

A subagent reports back to its caller through a dedicated hand-back call that the classifier reviews, rather than its last message being reviewed after the fact. In practice this means a subagent that went off-script gets caught at the boundary, not after its summary was already accepted.

### Monitor watches

Monitor watches always have a deadline now -- at most 30 minutes, 10 minutes in single-prompt `-p` runs -- and notify Claude to re-arm when they expire. The old no-timeout persistent watch is gone; long-running watchers need explicit re-arm logic.

## Where auto mode fits your workflow

- **Everyday feature work** -- the intended home. Prompts drop to a handful per hour.
- **Large refactors** -- combine with plan mode first; auto mode does not review the plan, only the actions.
- **CI and unattended runs** -- still use explicit allowlists plus `--dangerously-skip-permissions` in containers. The classifier is a latency and attention optimization, not an unattended-run guarantee.
- **Learning a new codebase** -- keep default mode. The prompts are a tour of what Claude is about to touch.

## When the classifier gets it wrong

Two failure directions, two fixes:

- **Denies something safe, repeatedly** -- do not train yourself to approve by reflex. Add an explicit allow rule for the exact pattern (`Bash(npm run test:*)`, not `Bash(*)`). Explicit rules are checked before the classifier, so the deny disappears and the reasoning stays auditable.
- **Allows something that worries you** -- add an `ask` rule for that command class. You keep the speedup everywhere else, and the sensitive category always stops for a human.

If whole classes of actions misbehave after a Claude Code update, check the release notes before blaming your rules -- auto mode's internals (inline `!` handling, hand-back review, Monitor deadlines) have changed several times since March 2026.

## Tips

- **Write allow rules for your hot path anyway.** Test commands, formatters, and your dev server should be allowlisted even under auto mode -- explicit rules are cheaper to evaluate and fully predictable.
- **Read the deny reasons.** The classifier surfaces why it refused. A surprising deny usually means the action was more dangerous than it looked, or your rule set contradicts itself.
- **Do not stack it with bypass.** Auto mode and `--dangerously-skip-permissions` are alternatives, not layers.
- **Sandboxing is a separate setting.** Auto mode benefits from it but does not force it. Turn sandboxing on explicitly for the protection to apply.
- **Watch the first hour.** The allow/ask/deny distribution tells you what to allowlist next. If everything is asking, your rules are too thin for auto mode to lean on.

## See Also

- [Permission Modes](permission-modes.md) -- The full mode landscape auto mode slots into
- [Security Practices](security-practices.md) -- Sandboxing, secrets, and safe default settings
- [CI and Automation](ci-and-automation.md) -- Unattended runs still want explicit allowlists
- [Hooks](hooks.md) -- Deterministic guards that complement the classifier
