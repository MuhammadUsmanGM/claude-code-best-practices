# Troubleshooting

Common issues you may encounter with Claude Code and how to fix them.

## Authentication Problems

**Symptom:** "Authentication failed" or "Invalid API key" errors.

**Fixes:**
- Verify your API key is set correctly in your environment or configuration
- Check that your key has not expired or been revoked in the Anthropic Console
- If using an IDE extension, re-enter your credentials in the extension settings
- Ensure there are no extra spaces or newline characters in your key

```bash
# Check if the key is set
echo $ANTHROPIC_API_KEY | head -c 10
# Should show the first 10 characters of your key
```

## Rate Limits

**Symptom:** "Rate limit exceeded" or 429 errors, responses stalling.

**Fixes:**
- Wait a minute and retry — rate limits reset quickly
- Use `/compact` to reduce context size, which reduces tokens per request
- Switch to a smaller model with `/model claude-haiku-4-5-20251001` for less contention
- If persistent, check your usage tier and billing limits in the Anthropic Console

## Context Too Long

**Symptom:** "Context length exceeded" errors, or Claude seems to forget earlier parts of the conversation.

**Fixes:**
- Run `/compact` immediately — this is the primary fix
- Run `/clear` and start a fresh session if compact is not enough
- Break your work into smaller sessions rather than one marathon conversation
- Avoid reading very large files in a single operation; read specific sections instead

```
# Instead of reading a 5000-line file
"read src/bigfile.ts lines 200-250"
```

## MCP Connection Failures

**Symptom:** MCP tools not appearing, "connection refused" errors, or MCP server not starting.

**Fixes:**
- Verify the MCP server is running and accessible
- Check the server URL and port in your MCP configuration
- Look at MCP server logs for startup errors
- Restart the MCP server and Claude Code
- Ensure firewall or network settings are not blocking the connection

```bash
# Check if MCP server is running
curl http://localhost:3000/health
```

## Hooks Not Firing

**Symptom:** Custom hooks (pre-commit, post-tool, etc.) are not executing.

**Fixes:**
- Verify hook configuration in your settings file
- Check that hook scripts are executable (`chmod +x`)
- Look at hook output — a failing hook may be silently erroring
- Ensure the hook path is correct and uses absolute paths
- Test the hook script manually outside of Claude Code

## Permission Errors

**Symptom:** "Permission denied" when Claude tries to read, write, or execute files.

**Fixes:**
- Check file permissions: `ls -la path/to/file`
- Ensure Claude Code has access to the directories it needs
- On macOS/Linux, check if the file is owned by a different user
- If using Docker or containers, verify volume mount permissions
- Review your permission mode settings — you may have restricted tool access too tightly

## Slow Responses

**Symptom:** Claude takes a long time to respond or seems to hang.

**Fixes:**
- Run `/compact` — large context is the most common cause of slowness
- Check your network connection
- The model may be under high load — try again in a few minutes
- Switch to a faster model: `/model claude-haiku-4-5-20251001`
- Avoid asking Claude to process very large files or outputs in a single step

## Claude Gives Wrong or Outdated Answers

**Symptom:** Claude suggests deprecated APIs, wrong syntax, or outdated patterns.

**Fixes:**
- Add project-specific conventions to your CLAUDE.md file
- Provide the relevant file or documentation as context: "read src/api.ts before answering"
- Correct Claude directly: "that API was deprecated — use newApi() instead"
- Be specific about versions: "I'm using React 19, not React 18"

## File Edits Not Working

**Symptom:** Claude's edits fail or produce unexpected results.

**Fixes:**
- Ensure the file is not locked by another process
- Check if the file has been modified since Claude last read it
- For large edits, ask Claude to read the file again before editing
- If an edit fails due to a uniqueness issue, ask Claude to include more surrounding context

## Unexpected Tool Denials

**Symptom:** Claude asks for permission on every action, or tools are blocked.

**Fixes:**
- Review your permission mode settings
- Check if a hook is intercepting and blocking tool calls
- Allow specific tools in your configuration if you trust them
- Use "always allow" when prompted for tools you use frequently

## Quick Diagnostic Checklist

When something is not working:

1. **Check the basics** — Is Claude Code running? Is your API key valid? Is the network up?
2. **Read the error message** — Claude Code surfaces specific error messages; read them carefully
3. **Compact or clear** — Many issues stem from large or confused context
4. **Restart** — Exit and relaunch Claude Code
5. **Check CLAUDE.md** — Misconfigured instructions can cause unexpected behavior
6. **Update** — Ensure you are running the latest version of Claude Code

## See Also

- [Tips and Tricks](./tips-and-tricks.md) — shortcuts and commands that help
- [Common Mistakes](./common-mistakes.md) — patterns that lead to problems
- [Cost Management](./cost-management.md) — managing token usage and rate limits
- [CLAUDE.md Setup](./claude-md-guide.md) — properly configuring project instructions
- [Debugging](debugging.md) — Debugging strategies for code issues
