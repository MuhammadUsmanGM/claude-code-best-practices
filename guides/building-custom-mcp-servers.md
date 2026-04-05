# Building Custom MCP Servers

The existing [MCP Servers](mcp-servers.md) guide covers configuring pre-built servers. This guide goes further -- it walks you through designing, building, testing, and deploying your own MCP servers to give Claude Code project-specific capabilities that no off-the-shelf server provides.

## When to Build a Custom Server

Build your own MCP server when:

- **Your tooling is project-specific.** Internal APIs, proprietary databases, or custom deployment systems that no public server covers.
- **You need to combine multiple data sources.** A single server that queries your database, checks your monitoring, and reads your config management.
- **You want to enforce guardrails.** Wrap dangerous operations with validation, confirmation logic, or audit logging.
- **Off-the-shelf servers are too broad.** You need a focused tool that does one thing well for your workflow.

## Architecture Overview

An MCP server is a process that communicates with Claude Code over a transport layer. The two supported transports are:

| Transport | How it works | Best for |
|-----------|-------------|----------|
| **stdio** | Claude Code spawns the server as a child process, communicates over stdin/stdout | Local development, project-specific tools |
| **HTTP (SSE)** | Server runs as a standalone HTTP service, Claude connects over the network | Shared team servers, remote tools, production APIs |

Most custom servers use stdio because it is simpler to set up and requires no networking configuration.

## Building a TypeScript Server

### Project setup

```bash
mkdir my-mcp-server && cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript tsx @types/node
```

### Minimal server with one tool

```typescript
// src/server.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "deploy-tools",
  version: "1.0.0",
});

server.tool(
  "check_deploy_status",
  "Check the current deployment status of a service",
  { service: z.string().describe("The service name to check") },
  async ({ service }) => {
    const status = await fetch(
      `https://deploy.internal/api/status/${service}`
    );
    const data = await status.json();
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Adding multiple tools

```typescript
server.tool(
  "list_services",
  "List all deployable services",
  {},
  async () => {
    const services = await fetch("https://deploy.internal/api/services");
    const data = await services.json();
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
);

server.tool(
  "get_recent_deploys",
  "Get recent deployments for a service",
  {
    service: z.string(),
    limit: z.number().default(5),
  },
  async ({ service, limit }) => {
    const deploys = await fetch(
      `https://deploy.internal/api/deploys/${service}?limit=${limit}`
    );
    const data = await deploys.json();
    return {
      content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
    };
  }
);
```

## Building a Python Server

```python
# server.py
from mcp.server.fastmcp import FastMCP
import httpx

mcp = FastMCP("deploy-tools")

@mcp.tool()
async def check_deploy_status(service: str) -> str:
    """Check the current deployment status of a service."""
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            f"https://deploy.internal/api/status/{service}"
        )
        return resp.text

@mcp.tool()
async def list_services() -> str:
    """List all deployable services."""
    async with httpx.AsyncClient() as client:
        resp = await client.get("https://deploy.internal/api/services")
        return resp.text

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

Install dependencies:

```bash
pip install mcp httpx
```

## Registering Your Server

Add the server to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "deploy-tools": {
      "command": "npx",
      "args": ["tsx", "./tools/mcp/src/server.ts"],
      "env": {
        "DEPLOY_API_TOKEN": "${DEPLOY_API_TOKEN}"
      }
    }
  }
}
```

For Python servers:

```json
{
  "mcpServers": {
    "deploy-tools": {
      "command": "python",
      "args": ["./tools/mcp/server.py"],
      "env": {
        "DEPLOY_API_TOKEN": "${DEPLOY_API_TOKEN}"
      }
    }
  }
}
```

Restart Claude Code after updating the configuration.

## Adding Resources and Prompts

Beyond tools, MCP servers can expose **resources** (data Claude can read) and **prompts** (reusable prompt templates).

### Resources

```typescript
server.resource(
  "service-config",
  "config://{service}",
  async (uri) => {
    const service = uri.pathname;
    const config = await loadConfig(service);
    return {
      contents: [{ uri: uri.href, text: JSON.stringify(config) }],
    };
  }
);
```

### Prompt templates

```typescript
server.prompt(
  "debug-service",
  "Debug a production service issue",
  { service: z.string(), error: z.string() },
  async ({ service, error }) => ({
    messages: [
      {
        role: "user",
        content: {
          type: "text",
          text: `Debug this issue with ${service}: ${error}. Check deploy status, recent changes, and logs.`,
        },
      },
    ],
  })
);
```

## Testing Your Server

### Manual testing

Run the server directly to verify it starts without errors:

```bash
npx tsx ./tools/mcp/src/server.ts
```

The process should start and wait for input on stdin. Press Ctrl+C to stop.

### Testing with Claude Code

1. Register the server in settings
2. Restart Claude Code
3. Run `/mcp` to verify the server appears and its tools are listed
4. Ask Claude to use one of the tools directly: "Use check_deploy_status to check the api-gateway service"

### Automated testing

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";

const server = createServer(); // your server factory
const transport = new InMemoryTransport();
await server.connect(transport);

const result = await transport.call("check_deploy_status", {
  service: "api-gateway",
});
assert(result.content[0].text.includes("status"));
```

## Design Best Practices

- **One server per domain.** Group related tools together (all deploy tools in one server, all monitoring tools in another). Do not build one mega-server.
- **Return structured data.** Use JSON for tool responses so Claude can parse and reason about the results.
- **Write clear descriptions.** The tool name and description are what Claude uses to decide when to call it. Be specific.
- **Validate inputs with Zod/Pydantic.** Strong input validation prevents confusing errors at runtime.
- **Handle errors gracefully.** Return error messages as text content rather than throwing exceptions. Claude can read and act on error messages.
- **Keep servers stateless.** Avoid storing state between calls. If state is needed, use an external store.
- **Log to stderr.** Never write logs to stdout -- that channel is reserved for MCP protocol messages.

## Security Considerations

- Store API keys and tokens in environment variables, not in source code
- Scope server permissions narrowly -- a deploy-status server should not have deploy-trigger permissions
- Validate all inputs before passing them to internal APIs
- Add rate limiting if the server calls external services
- Review third-party dependencies carefully -- your MCP server runs with your user permissions

## See Also

- [MCP Servers](mcp-servers.md) -- Configuring pre-built MCP servers
- [MCP Config Examples](../examples/mcp-configs.md) -- Ready-to-use server configurations
- [Hooks](hooks.md) -- Another way to extend Claude Code behavior
- [Security Practices](security-practices.md) -- Keeping credentials safe
