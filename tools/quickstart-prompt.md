# Quickstart Prompt

Copy and paste this prompt into Claude Code to auto-generate a CLAUDE.md for your project. No script needed — just run `claude` in your project directory and paste this:

```text
Analyze this project and generate a CLAUDE.md file for it. Read package.json (or pyproject.toml, Cargo.toml, go.mod, etc.), the directory structure, and any existing config files (tsconfig, eslint, prettier, etc.).

The CLAUDE.md should include:
1. Project name and one-line description
2. Tech stack (language, framework, key libraries)
3. Project structure (top-level directories and what they contain)
4. Commands: install, dev/build, test (all and single), lint, format
5. Code style rules (inferred from linter configs and existing code patterns)
6. Commit message convention (inferred from git log)
7. Any other important context you find (env vars, database setup, etc.)

Keep it concise — under 60 lines. Use bullet points, not paragraphs. Write commands with backticks. Do not include anything you are not confident about.
```

## When to Use This

- You want a CLAUDE.md right now with zero setup
- You are onboarding onto an unfamiliar codebase
- You want Claude to infer conventions from the code itself rather than answering questions manually

## After Generating

Review the output and adjust:

- Remove anything inaccurate
- Add team-specific rules Claude could not infer (PR process, deploy steps, etc.)
- Commit the file so your whole team benefits
