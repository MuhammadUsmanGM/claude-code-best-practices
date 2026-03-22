# Team and Organization Setup

Claude Code works well for individual developers, but its real leverage comes when an entire team shares consistent configuration. This guide covers how to structure `CLAUDE.md` files, settings, and permissions so that every team member gets the same high-quality experience from day one.

## Sharing CLAUDE.md Across a Team

Commit your `CLAUDE.md` to the repository root. This file becomes the shared source of truth for project conventions, architecture notes, and Claude Code instructions that every team member benefits from.

**What goes in the repo-root `CLAUDE.md` (committed):**

- Project architecture overview
- Coding standards and naming conventions
- Common commands (`npm test`, `npm run build`, etc.)
- File structure explanations
- Frameworks, libraries, and patterns in use

**What goes in per-package `CLAUDE.md` files (committed, monorepos):**

```
monorepo/
  CLAUDE.md              # Shared conventions for the whole repo
  packages/
    api/
      CLAUDE.md          # API-specific: endpoints, DB patterns, auth
    web/
      CLAUDE.md          # Frontend-specific: component style, state management
    shared/
      CLAUDE.md          # Shared utilities, types, conventions
```

Each package-level `CLAUDE.md` contains context specific to that package. Claude Code reads the nearest `CLAUDE.md` relative to the files it is working on.

**What goes in `~/.claude/CLAUDE.md` (never committed):**

- Personal preferences (editor style, verbosity)
- Individual workflow shortcuts
- Machine-specific paths or tool versions

Keep personal preferences out of the repo. The user-level file is for things that vary by person, not by project.

## The Settings Hierarchy

Claude Code merges settings from multiple levels. Understanding the precedence order prevents surprises.

| Level | Location | Committed? | Scope | Examples |
|---|---|---|---|---|
| Enterprise | Managed by organization admin | N/A | All users in org | Allowed MCP servers, enforced permission modes |
| Project | `.claude/settings.json` | Yes | All users on this repo | Tool allowlists, project-specific MCP servers |
| User | `~/.claude/settings.json` | No | Only you, all projects | Personal MCP servers, default preferences |

**Precedence order: Enterprise > Project > User.**

Enterprise policies always win. Project settings override user settings for that repository. User settings apply as defaults when no higher-level setting exists.

This means if an enterprise policy restricts an MCP server, no project or user setting can override that restriction. Plan your configuration accordingly.

## Standardizing Tool Allowlists

Put shared permission allowlists in the project-level `.claude/settings.json` so every team member starts with the same approved set of tools.

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Bash(npm run build)",
      "Bash(npx tsc --noEmit)",
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git log)"
    ]
  }
}
```

This configuration lets Claude Code edit files and run common development commands without prompting, while still requiring approval for anything outside the list. Commit this file so the entire team shares the same permissions.

**Avoid adding broad patterns** like `Bash(npm run *)` -- be explicit about which scripts are allowed. Review the allowlist when you add new scripts to `package.json`.

## Onboarding New Team Members

When your project is properly configured, onboarding is straightforward:

1. **Install Claude Code**
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **Authenticate**
   ```bash
   claude
   # Follow the interactive login flow
   ```

3. **Pull the repository**
   ```bash
   git clone <repo-url>
   cd <project>
   ```
   The committed `CLAUDE.md` and `.claude/settings.json` are already in place.

4. **Verify MCP servers load**
   ```bash
   claude
   # Type: /mcp
   # Confirm all configured servers show as connected
   ```

5. **Run a test prompt**
   Ask Claude something project-specific to verify the full setup:
   ```
   > Explain the project structure and run the test suite.
   ```
   If Claude understands the architecture and tests pass, the setup is complete.

## Enterprise Configuration

Organizations can enforce policies across all users through managed configuration.

**Managed policies support:**

- Restricting which MCP servers can be used (allowlist of approved servers)
- Enforcing minimum permission modes (e.g., no permissive mode on production repos)
- Setting default tool allowlists that projects cannot weaken
- Requiring specific hooks for compliance logging

Enterprise settings are distributed through your organization's admin tooling and cannot be overridden by project or user settings. Work with your organization admin to configure policies that balance security with developer productivity.

**Common enterprise patterns:**

- Allow only internally-hosted MCP servers
- Require PostToolUse audit hooks on all repositories
- Block `--dangerously-skip-permissions` globally
- Enforce a standard `.claudeignore` template

## Tips for Consistency

- **Use hooks for auto-formatting.** Configure a PostToolUse hook that runs your formatter (Prettier, Black, gofmt) after file edits. This ensures Claude's output always matches your team's style. See [hooks.md](hooks.md) for setup details.
- **Pin MCP server versions.** Specify exact versions in your MCP configuration to prevent unexpected behavior from upstream updates.
- **Document custom tools in CLAUDE.md.** If your project uses custom MCP servers or specialized scripts, describe them in `CLAUDE.md` so Claude knows when and how to use them.
- **Regular CLAUDE.md reviews.** Add `CLAUDE.md` review to your team's periodic processes (sprint retros, quarterly reviews). As the project evolves, the instructions should evolve with it.
- **Use `.claudeignore` consistently.** Maintain a shared `.claudeignore` that covers common sensitive patterns. Review it alongside `.gitignore` updates.
- **Test your configuration.** After changing settings or `CLAUDE.md`, have a team member run a standard prompt to verify the experience is consistent.

## See Also

- [CLAUDE.md Guide](claude-md-guide.md) -- writing effective project instructions
- [Permission Modes](permission-modes.md) -- understanding and configuring permission levels
- [MCP Servers](mcp-servers.md) -- configuring external tool integrations
- [Security Practices](security-practices.md) -- protecting secrets and auditing actions
