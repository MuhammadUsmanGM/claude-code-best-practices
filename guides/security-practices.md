# Security Practices

Claude Code has deep access to your development environment -- it can read files, execute commands, and interact with external services through MCP servers. This power demands careful security practices. This guide covers how to protect secrets, limit exposure, and audit what Claude does in your projects.

## Secrets Management

Never hardcode tokens, API keys, or credentials in any file that Claude Code reads or that gets committed to version control. This includes `CLAUDE.md`, `.claude/settings.json`, and MCP server configurations.

**Bad -- token hardcoded in MCP config:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "ghp_a1b2c3d4e5f6g7h8i9j0realtoken"
      }
    }
  }
}
```

**Good -- token referenced from environment variable:**

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

Store actual values in a `.env` file and make sure it is listed in `.gitignore`:

```bash
# .env (never committed)
GITHUB_TOKEN=ghp_a1b2c3d4e5f6g7h8i9j0realtoken
DATABASE_URL=postgres://user:pass@localhost/mydb
```

## The .claudeignore File

The `.claudeignore` file tells Claude Code which files and directories to skip entirely. It uses the same syntax as `.gitignore` and should be placed at your project root.

Claude Code will not read, index, or reference any file that matches a pattern in `.claudeignore`. This is your primary tool for keeping sensitive files out of the context window.

**Example `.claudeignore`:**

```
.env
.env.*
credentials/
*.pem
*.key
secrets.yaml
node_modules/
```

Place this file at the root of your repository alongside `CLAUDE.md`. It applies recursively to subdirectories. Use it liberally -- there is no cost to ignoring files that Claude does not need.

## What NOT to Expose to Claude

Even with `.claudeignore` in place, be deliberate about what data enters your Claude Code sessions.

| Data Type | Risk | Mitigation |
|---|---|---|
| API keys / tokens | Leakage into context, accidental commit | `.env` + `.claudeignore` + `.gitignore` |
| Database credentials | Unauthorized access to data stores | Environment variables, vault references |
| PII / customer data | Privacy violations, regulatory exposure | Use anonymized seed data for development |
| Production configs | Accidental changes to live systems | Separate prod configs, restrict file access |
| Private keys / certificates | Complete compromise of encrypted channels | Store outside repo, use `.claudeignore` |

## Safe Permission Patterns

Apply the principle of least privilege when configuring Claude Code permissions.

**Default to a restrictive mode for sensitive repositories.** Only allowlist commands you have reviewed and trust. Never grant broad shell access on projects that contain production credentials or infrastructure code.

| Scenario | Recommended Permission Mode |
|---|---|
| Open-source library development | Default (prompt per action) |
| Application with secrets in env | Default with specific allowlist |
| Infrastructure / DevOps repo | Restricted -- allowlist only read + lint |
| Quick prototyping (no secrets) | Permissive is acceptable |
| CI/CD pipeline integration | Locked to specific commands only |

**Key rules:**

- Allowlist only safe, read-only, or idempotent commands like `npm test`, `npm run lint`, and `tsc --noEmit`.
- Never use `--dangerously-skip-permissions` on repositories that contain production code, secrets, or infrastructure definitions.
- Review your `.claude/settings.json` allowlist periodically to remove stale entries.
- When in doubt, keep the default prompt-per-action mode -- the small friction is worth the safety.

## Auditing Claude's Actions

Trust but verify. Claude Code provides several mechanisms for reviewing what it has done.

**Use PostToolUse hooks to log actions.** You can configure hooks that run after every tool invocation, capturing what files were edited or what commands were executed. See [hooks.md](hooks.md) for configuration details.

**Always review diffs before committing.** After a Claude Code session, inspect changes carefully:

```bash
# See all uncommitted changes
git diff

# See a summary of changed files
git diff --stat

# Review the last commit if Claude already committed
git log -1 --stat
git diff HEAD~1
```

**Check for unintended file creation.** Claude may create files you did not expect. Use `git status` to catch untracked files before staging.

**Review MCP server interactions.** If Claude used external tools through MCP servers, verify the results are correct. MCP actions may have side effects beyond your local filesystem.

## Security Checklist

- [ ] All secrets are in `.env` files, never in `CLAUDE.md` or committed configs
- [ ] `.env` and credential files are listed in both `.gitignore` and `.claudeignore`
- [ ] MCP server configs reference environment variables, not literal tokens
- [ ] `.claudeignore` covers sensitive directories (`credentials/`, `*.pem`, `*.key`)
- [ ] Permission mode is appropriate for the repository's sensitivity level
- [ ] Tool allowlist includes only safe, reviewed commands
- [ ] `--dangerously-skip-permissions` is never used on production repos
- [ ] PostToolUse hooks log actions for audit trails
- [ ] All diffs are reviewed before commits are pushed
- [ ] Team members understand and follow these practices

## See Also

- [Permission Modes](permission-modes.md) -- configuring and understanding permission levels
- [MCP Servers](mcp-servers.md) -- secure configuration of external tool servers
- [Common Mistakes](common-mistakes.md) -- security-related pitfalls to avoid
- [Hooks](hooks.md) -- setting up audit logging with PostToolUse hooks
