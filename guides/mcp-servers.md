# Setting Up MCP Servers

The Model Context Protocol (MCP) extends Claude Code with additional tools and data sources. By connecting MCP servers, you can give Claude access to databases, APIs, file systems, and custom functionality beyond its built-in capabilities.

## What Is MCP?

MCP is an open protocol that defines how AI assistants communicate with external tool providers. Each MCP server exposes a set of tools that Claude Code can call, just like its built-in tools. The protocol handles discovery, invocation, and result formatting automatically.

Key concepts:

- **MCP Server** — A process that exposes tools over the MCP protocol
- **Transport** — How Claude Code communicates with the server (stdio or HTTP)
- **Tool** — A single capability the server provides (e.g., "query database", "list files")

## Configuring MCP Servers

MCP servers are configured in `.claude/settings.json` at the project level or `~/.claude/settings.json` globally:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    }
  }
}
```

Each entry specifies:

- **command** — The executable to run
- **args** — Arguments passed to the command
- **env** — Environment variables the server needs (API keys, tokens, etc.)

After updating the configuration, restart Claude Code for changes to take effect.

## Popular MCP Servers

### Filesystem Server

Provides sandboxed file access to specific directories. Useful for giving Claude access to directories outside the project root.

```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/data/shared"]
}
```

### GitHub Server

Enables creating issues, reading pull requests, managing repositories, and other GitHub operations beyond what the built-in `gh` CLI offers.

### PostgreSQL Server

Gives Claude read access to query your database schema and data. Useful for debugging data issues or generating queries.

```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres"],
  "env": {
    "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/mydb"
  }
}
```

### Other Notable Servers

- **Slack** — Read and send messages in Slack channels
- **Puppeteer** — Browser automation and web scraping
- **Memory** — Persistent key-value storage across sessions
- **Brave Search** — Web search capabilities

Find more servers at the MCP servers repository and community listings.

## Creating Custom MCP Servers

You can build your own MCP server for project-specific tooling. A minimal server in TypeScript:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "my-tools", version: "1.0.0" });

server.tool(
  "lookup_user",
  "Find a user by email address",
  { email: z.string().email() },
  async ({ email }) => {
    const user = await db.users.findByEmail(email);
    return { content: [{ type: "text", text: JSON.stringify(user) }] };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

Register it in your project settings:

```json
"my-tools": {
  "command": "npx",
  "args": ["tsx", "./tools/my-server.ts"]
}
```

## Debugging MCP Issues

Common problems and solutions:

- **Server not appearing** — Restart Claude Code after changing settings. Check that the command is in your PATH.
- **Tools not loading** — Run the server command manually in a terminal to see startup errors.
- **Authentication failures** — Verify environment variables are set correctly. Tokens may have expired.
- **Timeout errors** — The server may be slow to start. Check for missing dependencies or network issues.
- **Permission denied** — Ensure the server binary is executable and any referenced paths are accessible.

Enable verbose logging by running Claude Code with `--mcp-debug` to see the full MCP communication.

## Security Considerations

- Never commit API keys or tokens in `.claude/settings.json`. Use environment variable references or a separate `.env` file.
- Scope filesystem access to the minimum directories needed.
- Review third-party MCP servers before installing — they run with your user permissions.
- Use project-level settings for project-specific servers and global settings only for universally useful tools.

## See Also

- [Getting Started](getting-started.md) — Basic Claude Code setup
- [Hooks](hooks.md) — Another way to extend Claude Code behavior
- [IDE Integration](ide-integration.md) — Using MCP servers alongside your editor
- [CLAUDE.md Guide](claude-md-guide.md) — Documenting MCP tools for your team
