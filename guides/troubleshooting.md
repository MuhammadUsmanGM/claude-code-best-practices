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

As of v2.1.92, **Opus 4.6 supports a 1M token context window** on Max, Team, and Enterprise plans, so hitting the ceiling is much less common when using Opus. Sonnet and Haiku have smaller windows and may hit this issue sooner. If you do hit it, or if Claude seems to forget earlier context (due to automatic compression):

**Fixes:**
- Run `/compact` immediately — this compresses history and frees space
- Run `/compact focus on [topic]` to keep specific context while compressing the rest
- Run `/clear` and start a fresh session if compact is not enough
- Break your work into smaller sessions — even with 1M tokens, marathon sessions degrade quality after many compression cycles
- Avoid reading very large files in a single operation; read specific sections instead

```
# Instead of reading a 5000-line file
"read src/bigfile.ts lines 200-250"
```

**Note:** With Opus on Max/Team/Enterprise, most sessions will never hit the 1M limit. If you are regularly running out, you may be reading too many files or running too many commands in a single session. Consider using subagents for heavy exploration -- they run in their own context window. If you are on Sonnet or Haiku, hitting context limits is more common -- use `/compact` proactively.

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

## Claude Ignores CLAUDE.md Instructions

**Symptom:** Claude does not follow rules from CLAUDE.md, uses wrong conventions, or ignores "Do NOT" sections.

**Fixes:**
- Verify the `CLAUDE.md` file is in the project root (or the directory you launched Claude Code from)
- Check for syntax issues -- CLAUDE.md must be valid Markdown
- Keep instructions concise and specific. Vague rules like "write clean code" are ignored; "use named exports, not default exports" is followed
- Place the most important rules at the top -- Claude weighs earlier content more heavily
- If using a monorepo, ensure per-package `CLAUDE.md` files are in the correct directories
- Run `/compact` -- a very long conversation may push CLAUDE.md context out of the active window

## Claude Gets Stuck in a Loop

**Symptom:** Claude repeatedly tries the same failing approach, runs the same command, or keeps editing and reverting the same file.

**Fixes:**
- Hit **Escape** immediately to interrupt
- Redirect with a specific alternative: "Stop. Use approach X instead of Y"
- Use `/compact` to clear confused context, then restate the task
- If Claude keeps failing a test, provide the exact error message and ask it to analyze before fixing
- Set `--max-turns` to limit how many iterations Claude can take

## Git Operations Fail

**Symptom:** Claude cannot commit, push, or interact with git.

**Fixes:**
- Check if you are in a git repository: `git status`
- Verify git user config is set: `git config user.name` and `git config user.email`
- Check if a rebase, merge, or cherry-pick is in progress: `git status` will show this
- If Claude created a commit you did not want: `git log -3` to review, then ask Claude to help fix it
- For permission issues on push: verify your SSH key or token is configured

## Node.js / npm Issues

**Symptom:** Claude's `npm` commands fail with dependency errors, `EACCES`, or version mismatches.

**Fixes:**
- Run `npm install` manually to ensure dependencies are up to date
- Check Node.js version: Claude may assume a different version than what is installed
- For `EACCES` errors: fix npm permissions rather than using `sudo`
- If `npx` commands fail, try installing the package globally first

## Large File or Binary Handling

**Symptom:** Claude tries to read a binary file, chokes on a huge file, or the context fills up from a single read.

**Fixes:**
- Add large/binary files to `.claudeignore`
- Ask Claude to read specific line ranges: "read lines 100-150 of src/bigfile.ts"
- For generated files (bundle.js, compiled output), add them to `.claudeignore`
- If context is full from a large read, run `/compact` or `/clear`

## IDE Extension Issues

**Symptom:** The VS Code or JetBrains extension does not connect, shows stale data, or behaves differently from the CLI.

**Fixes:**
- Ensure the CLI version and extension version are compatible -- update both
- Restart the IDE after updating the extension
- Check the extension output panel for error messages
- Verify that the extension is using the same API key as the CLI

## Session Recovery

**Symptom:** You lost a conversation due to a crash, network drop, or accidental `/clear`.

**Fixes:**
- Use `claude --resume` to resume the most recent session
- Use `claude --resume <session-id>` if you know the specific session
- Check `~/.claude/` for session files if needed
- Git history preserves all file changes Claude made, even if the session is lost

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
