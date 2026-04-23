# Custom Instructions and Personas

CLAUDE.md files do more than document your project — they shape how Claude Code behaves. By writing targeted instructions, you can create specialized personas that make Claude act as a code reviewer, architect, security auditor, or any other role your workflow requires.

## How Custom Instructions Work

Claude reads every CLAUDE.md file in your project hierarchy before responding. Instructions in these files influence tone, focus, output format, and decision-making. The more specific your instructions, the more consistent Claude's behavior becomes.

The hierarchy loads in order:

1. `~/.claude/CLAUDE.md` — Global defaults for all projects
2. `~/project/CLAUDE.md` — Project-level context
3. `~/project/src/CLAUDE.md` — Directory-specific overrides

Later files take precedence, so directory-level instructions override project-level ones.

## Writing Effective Instructions

### Be Direct and Specific

Claude follows explicit instructions more reliably than vague preferences:

````markdown
## Code Style
- Use early returns instead of nested if/else blocks
- Maximum function length: 30 lines. Extract helpers for anything longer.
- Name boolean variables with is/has/should prefixes
- Never use `any` in TypeScript. Define proper types or use `unknown`.
````

### State What To Do, Not Just What to Avoid

Positive instructions are clearer than negative ones:

````markdown
## Good
- Use Zod schemas for all API input validation
- Write error messages that tell the user what to do next

## Less Effective
- Don't use manual validation
- Don't write bad error messages
````

### Include Examples

Short examples anchor abstract instructions:

````markdown
## Commit Messages
Format: <type>(<scope>): <description>

Examples:
- feat(auth): add OAuth2 login with Google
- fix(cart): prevent negative quantities on update
- refactor(api): extract validation middleware
````

## Persona Patterns

### The Strict Reviewer

Add this to your project CLAUDE.md when you want Claude to catch issues aggressively:

````markdown
## Review Mode
When reviewing code, be thorough and critical:
- Flag any function without error handling
- Call out missing input validation on public APIs
- Reject magic numbers — require named constants
- Check that every async function has proper error boundaries
- Verify that database queries use parameterized inputs, never string concatenation
- If a test is missing for new functionality, say so explicitly
````

### The Senior Architect

For design discussions and technical planning:

````markdown
## Architecture Mode
When discussing design decisions:
- Consider scalability implications for each approach
- Evaluate trade-offs explicitly: performance vs complexity, flexibility vs simplicity
- Reference existing patterns in this codebase before suggesting new ones
- Suggest the simplest solution that meets current requirements
- Flag when a decision will be hard to reverse later
````

### The Security Auditor

For security-focused sessions:

````markdown
## Security Review
Analyze all code changes through a security lens:
- Check for OWASP Top 10 vulnerabilities in every change
- Verify that user input is sanitized before reaching the database, file system, or shell
- Ensure authentication checks exist on all protected routes
- Flag any secrets, tokens, or credentials in code — even in examples
- Check that CORS, CSP, and rate limiting are properly configured
````

### The Documentation Writer

When generating docs or comments:

````markdown
## Documentation Style
- Write JSDoc for all exported functions with @param, @returns, and @example
- Use present tense in descriptions ("Returns the user" not "Will return the user")
- Include one usage example per documented function
- Keep descriptions under two sentences
- Document why, not what — the code shows what it does
````

## Role Switching

You can switch Claude's behavior mid-session by referencing a role:

```bash
claude "Review this PR as a security auditor. Focus only on auth and input validation."
claude "Now review the same changes as a performance engineer. Look for N+1 queries and unnecessary allocations."
```

Or create role-specific CLAUDE.md files in subdirectories:

```
project/
  CLAUDE.md                    # General project context
  src/
    CLAUDE.md                  # Dev instructions for source code
  docs/
    CLAUDE.md                  # Documentation-style instructions
  security/
    CLAUDE.md                  # Security-focused review rules
```

## Team Personas

Share persona configurations across your team by committing them to version control:

````markdown
# .claude/CLAUDE.md (committed to repo)

## Team Standards
- All PRs require tests for new functionality
- Use conventional commit format
- API changes need updated OpenAPI specs
- No console.log in production code — use the logger utility
````

Individual developers can add personal preferences in their global config without affecting the team:

````markdown
# ~/.claude/CLAUDE.md (personal, not committed)

## My Preferences
- Explain changes briefly after making them
- Use verbose variable names
- Show me the diff after edits
````

## Conditional Instructions

Use section headers to scope instructions to specific contexts:

````markdown
## When Writing Tests
- Use describe/it blocks, not test() standalone
- One assertion per test when possible
- Name tests as "it should [expected behavior] when [condition]"

## When Refactoring
- Never change external behavior
- Run tests after every file change
- Preserve existing test coverage

## When Reviewing PRs
- Check for breaking changes in public APIs
- Verify backward compatibility
- Ensure migration steps are documented
````

Claude applies the relevant section based on what you ask it to do.

## Measuring Effectiveness

To check if your instructions are working:

1. **Ask Claude to explain its approach** before it starts work: "Before you begin, tell me what rules you're following for this task"
2. **Review output consistency** across sessions — if Claude formats things differently each time, your instructions need to be more specific
3. **Iterate on instructions** when Claude deviates. Add the correction as an explicit rule rather than repeating it each time

## See Also

- [CLAUDE.md Guide](claude-md-guide.md) -- Fundamentals of writing CLAUDE.md files
- [Team Setup](team-setup.md) -- Sharing instructions across your team
- [Prompt Tips](prompt-tips.md) -- Writing effective prompts that complement your instructions
- [Security Practices](security-practices.md) -- Security-focused instruction patterns
