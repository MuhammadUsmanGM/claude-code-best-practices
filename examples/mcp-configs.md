# Example MCP Server Configurations

These are ready-to-use `.claude/settings.json` snippets for popular MCP servers. Each entry goes inside the `mcpServers` object in your settings file. For background on MCP, see the [MCP Servers Guide](../guides/mcp-servers.md).

## GitHub Server

Gives Claude access to GitHub tools: create/read issues, read pull requests, list repositories, and more.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

Generate a fine-grained personal access token at GitHub Settings > Developer settings > Personal access tokens. Grant only the repository permissions you need (Issues read/write, Pull Requests read, etc.).

## PostgreSQL Server

Gives Claude read access to your database schema and data for queries and debugging.

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://readonly_user:password@localhost:5432/mydb"
      }
    }
  }
}
```

Always use read-only database credentials. Create a dedicated role with `GRANT SELECT` on the tables Claude needs. Never expose credentials with write or DDL permissions.

## Filesystem Server

Gives Claude access to specific directories outside the project root, useful for shared documentation or data files.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y", "@modelcontextprotocol/server-filesystem",
        "/path/to/shared-docs",
        "/path/to/data"
      ]
    }
  }
}
```

Each positional argument is a directory the server exposes. Claude can read and write files within these directories. Omit directories you do not want Claude to access.

## Slack Server

Gives Claude the ability to read channels, post messages, and search Slack history.

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-bot-token"
      }
    }
  }
}
```

Required OAuth scopes for the Slack app: `channels:history`, `channels:read`, `chat:write`, `users:read`. Add `groups:read` and `groups:history` if you need private channel access. Configure these in your Slack app's OAuth & Permissions page.

## Custom Project Server

You can write a minimal MCP server to expose project-specific tools. Here is a TypeScript example that provides a `lookup_user` tool.

`tools/mcp-user-lookup.ts`:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "user-lookup", version: "1.0.0" });

server.tool("lookup_user", { email: z.string().email() }, async ({ email }) => {
  const user = await db.users.findByEmail(email); // your DB logic
  return {
    content: [{ type: "text", text: JSON.stringify(user, null, 2) }],
  };
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Register it in settings:

```json
{
  "mcpServers": {
    "project-tools": {
      "command": "npx",
      "args": ["tsx", "tools/mcp-user-lookup.ts"]
    }
  }
}
```

## Multi-Server Setup

A complete configuration combining multiple servers. This goes in `.claude/settings.json`.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://readonly_user:password@localhost:5432/mydb"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y", "@modelcontextprotocol/server-filesystem",
        "/path/to/shared-docs"
      ]
    }
  }
}
```

Set sensitive values as environment variables rather than hardcoding them. For example, use `$GITHUB_PERSONAL_ACCESS_TOKEN` and ensure the variable is set in your shell profile. Each server runs as a separate process and Claude discovers their tools at startup.

## See Also

- [MCP Servers Guide](../guides/mcp-servers.md) — how MCP works, configuration details, and troubleshooting
- [Security Practices](../guides/security-practices.md) — credential management and access control
- [Team Setup](../guides/team-setup.md) — sharing MCP configurations across a team
