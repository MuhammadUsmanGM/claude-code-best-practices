# Enterprise and Org-Scale Patterns

Individual developers can pick up Claude Code and be productive in minutes. Scaling it across a 50-person team or a 500-person organization requires deliberate governance, configuration management, and access control. This guide covers the patterns that work at enterprise scale.

## The Configuration Hierarchy at Scale

Claude Code merges settings from three levels. In an organization, understanding this hierarchy is critical because misconfigured precedence causes inconsistent behavior across teams.

| Level | Location | Who controls it | Overrides |
|-------|----------|----------------|-----------|
| Enterprise | Managed policy (admin-distributed) | Platform / security team | Everything below |
| Project | `.claude/settings.json` in repo | Team lead / repo owner | User settings |
| User | `~/.claude/settings.json` | Individual developer | Nothing above |

**Enterprise policies always win.** If a security team blocks an MCP server at the enterprise level, no project or user setting can re-enable it.

## Governance Framework

### Centralized policy management

Define organization-wide policies that enforce security baselines across all repositories:

```json
{
  "permissions": {
    "deny": [
      "Bash(rm -rf *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)"
    ]
  },
  "mcpServers": {
    "allowlist": ["@modelcontextprotocol/*", "@your-org/*"],
    "blockUnlisted": true
  },
  "flags": {
    "blockDangerouslySkipPermissions": true,
    "requirePlanMode": false
  }
}
```

### Policy distribution

Distribute enterprise settings through your existing configuration management:

- **MDM / endpoint management** -- Push `~/.claude/enterprise-settings.json` via Jamf, Intune, or similar
- **Login scripts** -- Copy enterprise config on shell initialization
- **Container images** -- Bake enterprise settings into your development container base images
- **Dotfiles repo** -- Include in your organization's standard dotfiles distribution

### Change management

Treat Claude Code policy changes like infrastructure changes:

1. Propose the change in a pull request to your policy repository
2. Review with security and platform engineering
3. Test in a staging group before rolling out org-wide
4. Communicate changes to developers with clear rationale
5. Monitor for unexpected breakage after rollout

## Access Control Patterns

### Tiered permission profiles

Different teams need different permission levels based on what they work on:

| Profile | Description | Key settings |
|---------|------------|-------------|
| **Standard** | Application development, no infra access | Default mode, allowlisted test/lint commands |
| **Elevated** | Backend services with database access | Standard + database MCP server, migration commands |
| **Infrastructure** | DevOps, platform, and SRE teams | Elevated + deploy commands, restricted to plan mode |
| **Restricted** | Security-sensitive repos (auth, payments) | Read-only tools, no bash, mandatory plan mode |

### Repository classification

Tag repositories by sensitivity level and auto-apply the appropriate permission profile:

```bash
# In your CI/CD or repo provisioning scripts
case "$REPO_CLASSIFICATION" in
  "public")
    cp policies/standard.json .claude/settings.json
    ;;
  "internal")
    cp policies/elevated.json .claude/settings.json
    ;;
  "restricted")
    cp policies/restricted.json .claude/settings.json
    ;;
esac
```

### MCP server allowlisting

Control which MCP servers developers can use:

- **Approved servers** -- Vetted by security, available to all teams
- **Team-specific servers** -- Internal tools scoped to specific teams
- **Blocked servers** -- Known-risky or redundant servers that should not be installed

Maintain an internal registry of approved MCP servers with version pinning.

## Shared Configuration at Scale

### Monorepo patterns

Large monorepos benefit from layered `CLAUDE.md` files:

```
company-monorepo/
  CLAUDE.md                    # Org-wide conventions
  .claude/settings.json        # Shared permissions
  services/
    auth/
      CLAUDE.md                # Auth-specific: security patterns, token handling
    payments/
      CLAUDE.md                # Payments: PCI compliance, audit logging
    frontend/
      CLAUDE.md                # Frontend: component library, design system
  packages/
    shared-types/
      CLAUDE.md                # Type conventions, export patterns
```

Each `CLAUDE.md` inherits from its parent and adds context specific to that area. Keep them focused -- 20-40 lines for package-level files, 40-80 lines for the root.

### Template repositories

Create starter templates that include pre-configured Claude Code settings:

```
org-service-template/
  CLAUDE.md                    # Standard service conventions
  .claude/settings.json        # Approved permissions and MCP servers
  .claudeignore                # Standard ignore patterns
```

When teams create new repositories from the template, they get a working Claude Code setup from the first commit.

### Configuration drift detection

Add a CI check that verifies Claude Code settings match your organization standards:

```yaml
# .github/workflows/claude-config-check.yml
name: Claude Config Compliance
on: [pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate Claude settings
        run: |
          # Check that required settings exist
          jq -e '.permissions.deny' .claude/settings.json
          # Check that blocked MCP servers are not present
          ! jq -e '.mcpServers["blocked-server"]' .claude/settings.json
          # Verify CLAUDE.md exists
          test -f CLAUDE.md
```

## Onboarding at Scale

### Self-service setup

Minimize manual onboarding steps by automating the environment:

```bash
#!/bin/bash
# onboard-claude-code.sh -- run once per developer machine
set -euo pipefail

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Apply enterprise settings
mkdir -p ~/.claude
curl -s https://internal.company.com/claude/enterprise-settings.json \
  > ~/.claude/enterprise-settings.json

# Verify setup
claude -p "echo 'Claude Code is configured correctly'" \
  --max-turns 1 2>/dev/null && echo "Setup complete." || echo "Setup failed."
```

### Training and documentation

- Maintain an internal wiki page linking to this best practices repo
- Run quarterly "Claude Code office hours" for tips and Q&A
- Create a shared Slack channel for Claude Code questions and discoveries
- Publish curated CLAUDE.md examples from successful internal projects

### Usage monitoring

Track adoption and usage across the organization:

- **API key management** -- Issue team-level API keys to track spend per team
- **Usage dashboards** -- Use the Anthropic Console to monitor token consumption
- **Periodic reviews** -- Quarterly review of costs, common use cases, and ROI

## Compliance and Audit

### Audit logging with hooks

Configure PostToolUse hooks that log every Claude Code action to your audit system:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "command": "bash -c 'echo \"{\\\"tool\\\": \\\"$TOOL_NAME\\\", \\\"timestamp\\\": \\\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\\\", \\\"user\\\": \\\"$USER\\\"}\" >> /var/log/claude-audit.jsonl'"
      }
    ]
  }
}
```

### Data residency

- Verify that your Anthropic API region matches your data residency requirements
- Use `.claudeignore` to prevent sensitive files from entering the context window
- Review MCP server data flows to ensure no data leaves approved boundaries

### Incident response

When a security incident involves Claude Code:

1. Check the audit log for the affected user and time window
2. Review `git log` for commits made during the session
3. Inspect MCP server logs for external API calls
4. Revoke and rotate any credentials that may have been exposed
5. Update enterprise policies to prevent recurrence

## See Also

- [Team Setup](team-setup.md) -- Sharing configs and onboarding teammates
- [Security Practices](security-practices.md) -- Secrets management and safe permission patterns
- [Permission Modes](permission-modes.md) -- Understanding permission levels
- [CI and Automation](ci-and-automation.md) -- Running Claude Code in pipelines
