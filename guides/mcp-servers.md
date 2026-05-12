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

## Handling Large Tool Results

By default, Claude Code truncates oversized MCP tool results to keep the model's context manageable. For a `list_files` call that returns 30 entries, this is a feature. For a database schema dump or a CSV that the model needs to reason over in full, it is the difference between a useful answer and a wrong one.

Claude Code v2.1.139 added a per-result override: an MCP server can annotate its response with `_meta["anthropic/maxResultSizeChars"]` to request a higher cap, up to 500,000 characters. Claude Code honours the annotation per-call; you do not configure it client-side.

### When to bump the cap

| Tool result | Default truncation is... | Set the cap to... |
|-------------|--------------------------|-------------------|
| Listing 20 services | Fine | Don't override |
| Recent 100 log lines | Fine | Don't override |
| Full database schema (`information_schema`) | Probably cut mid-table | 100K -- 250K |
| Large query result for analysis | Cut to ~the first page | Up to 500K, paginate if larger |
| Full file tree of a 5K-file monorepo | Cut after a few directories | 200K |
| Production stack trace with full request context | Usually fine | Don't override |

Rule of thumb: only override when the model needs the *entire* result to reason correctly. Pagination or filtering at the server is almost always better than maxing out the cap.

### Setting the annotation

If you maintain the server, set the annotation on the response. See [Building Custom MCP Servers](building-custom-mcp-servers.md) for full code samples. If you do not maintain the server, file an issue upstream -- this is a server-side setting, not a Claude Code config.

## Debugging MCP Issues

Common problems and solutions:

- **Server not appearing** — Restart Claude Code after changing settings. Check that the command is in your PATH.
- **Tools not loading** — Run the server command manually in a terminal to see startup errors.
- **Authentication failures** — Verify environment variables are set correctly. Tokens may have expired.
- **Timeout errors** — The server may be slow to start. Check for missing dependencies or network issues.
- **Permission denied** — Ensure the server binary is executable and any referenced paths are accessible.

Enable verbose logging by running Claude Code with `--mcp-debug` to see the full MCP communication.

## Recommended Servers for SaaS Development

These are high-value MCP servers that most development teams benefit from. Install the ones that match your stack.

### GitHub — PR and Issue Management

Manage pull requests, issues, and code review without leaving your terminal:

```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
  }
}
```

Use cases: create PRs from Claude's changes, review PRs inline, triage issues, check CI status.

### PostgreSQL — Schema Exploration and Queries

Give Claude read access to your database for debugging data issues and generating queries:

```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres"],
  "env": {
    "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/mydb"
  }
}
```

Use cases: explore schema, debug bad data, write and test complex queries, verify migrations.

### Linear — Sync Code to Tickets

Connect code changes to your project management workflow:

```json
"linear": {
  "command": "npx",
  "args": ["-y", "@agentic/linear-mcp"],
  "env": {
    "LINEAR_API_KEY": "lin_api_xxxxxxxxxxxx"
  }
}
```

Use cases: reference ticket context in prompts, auto-update ticket status, pull acceptance criteria into Claude's context.

### Sentry — Error Monitoring

Pull real production errors into your debugging sessions:

```json
"sentry": {
  "command": "npx",
  "args": ["-y", "@sentry/mcp-server"],
  "env": {
    "SENTRY_AUTH_TOKEN": "sntrys_xxxxxxxxxxxx"
  }
}
```

Use cases: fetch the latest errors, get stack traces with context, correlate errors with recent deploys.

### Brave Search — Web Search

Give Claude the ability to search the web for documentation, error messages, and library references:

```json
"brave-search": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-brave-search"],
  "env": {
    "BRAVE_API_KEY": "BSA_xxxxxxxxxxxx"
  }
}
```

Use cases: look up library APIs, find solutions to obscure errors, check latest documentation.

### Finding More Servers

For a comprehensive directory of community MCP servers, see the [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers) repository. Evaluate third-party servers carefully before installing — they run with your user permissions.

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
- [Building Custom MCP Servers](building-custom-mcp-servers.md) -- Full guide to designing and building your own MCP servers
- [Security Practices](security-practices.md) -- Keeping MCP credentials safe
- [MCP Config Examples](../examples/mcp-configs.md) -- Ready-to-use server configurations
