# Agent View

`claude agents` (added in Claude Code v2.1.139) is a single dashboard of every Claude Code session on your machine -- running, blocked on you for input, or done. It replaces the "did I leave a session in tmux pane 4?" problem with one place to look.

## What it shows

Run `claude agents` from any directory. You get a list of every active and recent session on the local machine, grouped by status. The list is global across projects, so a session you started in one repo shows up alongside sessions from another -- handy when you cannot remember where you left work running:

| Status | Meaning | What to do |
|--------|---------|-----------|
| **Running** | Claude is mid-turn, executing tools | Wait or attach to watch |
| **Blocked on you** | Claude finished a turn, needs your next prompt or a permission decision | Attach and respond |
| **Idle** | Session is open but no prompt in flight | Attach to resume |
| **Done** | Session ended cleanly | Read transcript or discard |

Each row shows the session's working directory, current model, elapsed time, token usage so far, and the last user prompt or summary. Select a row to attach to that session's terminal.

## When to use it vs. tmux or worktrees

`claude agents` is not a replacement for tmux or git worktrees. It is a discovery layer on top of whatever you already use to run multiple sessions.

| You want to... | Use |
|----------------|-----|
| Run two sessions on the same repo without conflicts | Git worktrees -- see [Multi-Agent](multi-agent.md) |
| Keep long-running sessions alive across SSH disconnects | tmux or screen, with `claude` inside a pane |
| Find which of your 6 open sessions is waiting on a permission prompt | `claude agents` |
| See which session ate 80K tokens debugging the same flaky test | `claude agents`, then attach and `/clear` |
| Spawn coordinated sub-agents from a team lead | `/teams`, not `claude agents` |

In practice: use worktrees to *isolate* parallel work, use tmux to *keep* sessions alive, and use `claude agents` to *find* the session you want when you have more than two open.

## Common workflows

### Triage what is waiting on you

You started three sessions before lunch. After lunch:

```bash
claude agents
```

Look for "blocked on you" rows. Those need a decision before they can make progress. Running rows are doing work -- leave them alone. Done rows can be reviewed later or pruned.

### Recover a session you forgot about

You closed a terminal tab two hours ago without ending the session. The session is still alive in the background. `claude agents` lists it -- attach to resume where you left off. Without the agent view, you would have to `ps aux | grep claude` and reattach manually.

### Spot a runaway session

A session has been "running" for 40 minutes on a task that should have taken 5. The token count is climbing. Attach, read what it has been doing, and either redirect with a new prompt or kill the session. The agent view surfaces this kind of drift far earlier than discovering it by accident the next morning.

### Cost retrospective at end of day

Sort the list by token usage. The session that burned 200K tokens is the one to learn from -- attach, scroll the transcript, and decide whether the prompt was vague, the task was too large, or the loop got stuck. See [Cost Management](cost-management.md) for what to do with the finding.

## Interaction with multi-agent teams

When you use `/teams` to spawn a team lead and teammates, each teammate is a separate Claude Code session. They all show up in `claude agents` as independent rows -- the team relationship is not rendered in the dashboard view.

This is useful for debugging team workflows:

- A teammate stuck on a permission prompt appears as "blocked on you" even though the team lead is also waiting. You can attach directly instead of routing through the lead.
- A teammate that crashed shows as "done" with an error in its summary. Attach to read the transcript before respawning.
- Cumulative token usage across the team is the sum of the rows -- handy for cost attribution on team-based feature work.

For coordinating the team itself (assigning tasks, watching task status), keep using the team lead's session. The agent view is the operating-system-level dashboard, not the team management UI.

### Reconnect to a session another teammate started

On a shared dev box, multiple users running `claude` produce a single list per Unix user. If you `su` or share an account, you see each other's sessions. This is useful for pairing but bad for accidental drift -- name your sessions with `/rename` to make ownership obvious.

## Keyboard and CLI tips

Inside the agent view:

- Arrow keys move between rows.
- `Enter` attaches to the selected session.
- `d` discards a "done" session and removes it from the list.
- `q` exits the dashboard without attaching.

From the shell, you can pipe the list:

```bash
claude agents --json | jq '.[] | select(.status == "blocked")'
```

This is useful in CI or in a personal status-line script that pings you when something is waiting.

## Tips

- **Make `claude agents` the first thing you run when you sit down.** It catches forgotten sessions before they pile up.
- **Discard done sessions you do not need.** The list is more useful when it is short.
- **Pair with `/rename` inside a session** to give long-running sessions human labels. Without a name, you are matching on working directory and last prompt, which gets ambiguous fast.
- **Do not use it as a team management tool.** It shows sessions, not task graphs. The team lead's view is still the authoritative status for a `/teams` run.
- **Discard, do not kill, when you can.** A session in "done" status has already released its lock cleanly. Using `kill -9` on a "running" session can leave its worktree in a half-edited state -- interrupt it from inside instead.
- **The dashboard is per-machine, not per-user.** If you run Claude Code on a laptop and a remote dev box, each has its own list. There is no cloud-side view.

## See Also

- [Multi-Agent](multi-agent.md) -- Teams, worktrees, and coordinated sub-agents
- [Goal Mode](goal-mode.md) -- Long-running `/goal` sessions are common candidates for the dashboard
- [Cost Management](cost-management.md) -- Use the dashboard to spot expensive sessions
- [Context Management](context-management.md) -- What to do once you find the session eating tokens
