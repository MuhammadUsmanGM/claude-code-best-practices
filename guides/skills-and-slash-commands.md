# Skills and Slash Commands

Skills extend Claude Code with specialized capabilities. Slash commands give you quick access to common actions without typing full prompts. Together, they make Claude Code more powerful and efficient.

## What Are Skills?

Skills are modular plugins that add domain-specific knowledge and workflows to Claude Code. Each skill is triggered automatically when your request matches its domain, or manually via a slash command.

Built-in skills include code review, commit generation, PR creation, and file simplification. Community and custom skills can be installed for specialized tasks like database management, API integration, or framework-specific workflows.

## Using Slash Commands

Type `/` followed by the command name to invoke a skill directly:

```bash
/commit          # Generate a commit with a meaningful message
/review-pr 42    # Review pull request #42
/simplify        # Review changed code for quality and efficiency
```

Run `/help` to see all available commands in your current session.

### Common Built-in Commands

| Command | What It Does |
|---------|-------------|
| `/commit` | Stage and commit changes with a generated message |
| `/review-pr` | Review a pull request with detailed feedback |
| `/simplify` | Analyze changed code for reuse and efficiency |
| `/help` | List available commands and usage info |
| `/clear` | Clear conversation history and start fresh |
| `/compact` | Compress conversation to save context |
| `/fast` | Toggle fast mode (same model, faster output) |

## Discovering Skills

Use the `find-skills` skill to search for installable skills:

```bash
/find-skills "semantic search"
/find-skills "docker"
```

This searches for community skills that match your needs and shows installation instructions.

## Installing Skills

Skills can be added at the project or global level. Project-level skills live in `.claude/skills/` and are shared with your team via version control:

```bash
# Skills are typically installed by adding their configuration
# to your project or global settings
```

Global skills in `~/.claude/skills/` apply to all your projects.

## Creating Custom Skills

You can build your own skills to automate repetitive workflows. A skill consists of a prompt template that Claude follows when the skill is triggered.

### Skill Structure

A custom skill needs:

- **Name** — A short identifier used as the slash command
- **Description** — Tells Claude when to trigger the skill automatically
- **Prompt** — The instructions Claude follows when the skill activates

### Example: Custom Deploy Skill

```markdown
# Deploy Skill

Trigger when the user asks to deploy or push to production.

## Steps

1. Run the test suite and confirm all tests pass
2. Check for uncommitted changes and commit if needed
3. Build the project with `npm run build`
4. Run `npm run deploy` and report the result
```

### Tips for Writing Skills

- **Be specific in the description** so the skill triggers at the right time and not for unrelated requests
- **Include guard rails** like "ask for confirmation before deploying"
- **Keep skills focused** on one workflow rather than combining multiple concerns
- **Test your skill** by invoking it directly with the slash command before relying on auto-triggering

## Skill Evaluation

Use the `skill-creator` skill to measure how well your custom skills perform:

```bash
/skill-creator eval my-skill
```

This runs your skill against test cases and reports accuracy, helping you refine the trigger description and prompt.

## Managing Skills

### Listing Active Skills

Skills available in your current session are shown with `/help`. The list depends on your global and project-level configurations.

### Disabling a Skill

Remove or comment out the skill configuration from your settings to disable it. Project-level skills in `.claude/skills/` can be removed from version control if the team no longer needs them.

### Updating Skills

Community skills may release updates. Check the skill's source repository for new versions and update your local copy accordingly.

## Best Practices

- **Start with built-in skills** before writing custom ones — they cover most common workflows
- **Use `/find-skills` first** to check if a community skill already exists for your use case
- **Version control project skills** so your whole team benefits from the same automation
- **Write clear trigger descriptions** to avoid skills firing unexpectedly
- **Keep skill prompts under 500 words** for faster execution and better focus

## See Also

- [Tips and Tricks](tips-and-tricks.md) -- Keyboard shortcuts and other CLI features
- [Workflow Patterns](workflow-patterns.md) -- Common development workflows that skills can automate
- [Hooks](hooks.md) -- Another automation mechanism that complements skills
- [Team Setup](team-setup.md) -- Sharing skills across your team
