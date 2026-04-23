# Contributing to Claude Code Best Practices

Thank you for your interest in improving this wiki. Whether you are fixing a typo, adding a new guide, or suggesting a restructuring, contributions are welcome.

## How to Contribute

1. **Fork** the repository and clone it locally.
2. **Create a branch** for your change (`git checkout -b add-guide-topic-name`).
3. **Make your changes** following the style guide below.
4. **Submit a pull request** with a clear description of what you changed and why.

For larger changes (new guides, structural reorganization, removing content), open an issue first to discuss the approach before investing time in a PR.

## Style Guide

All wiki files follow these conventions:

- **H1 title** matching the topic of the guide, one per file
- **H2 for main sections**, H3 for subsections within them
- **Target 100-180 lines** per guide to keep content focused and readable
- **Fenced code blocks** with language tags for all code samples:
  - Use `json`, `bash`, `typescript`, `markdown`, `python`, or other appropriate tags
  - Never use bare fenced blocks without a language identifier
- **Tables** for comparisons, option references, and quick-lookup information
- **Bullet points** for lists of items, steps, or options
- **"See Also" section** at the bottom of every guide with 3-4 relative links to related guides
- **No emojis** anywhere in guide content
- **Practical, actionable content** over theory -- readers should be able to apply what they read immediately

### Formatting checklist

| Element | Convention |
|---------|-----------|
| Headings | H1 for title, H2 for sections, H3 for subsections |
| Code blocks | Fenced with language tag (` ```json `, ` ```bash `, etc.) |
| Lists | Bullet points with bold lead-in where helpful |
| Cross-references | Relative links only (see Link Conventions) |
| Line count | 100-180 lines per guide |
| Tone | Direct, second-person ("you"), no filler |

## Link Conventions

All internal links use relative paths. Never use absolute URLs for links between wiki files.

| From | To | Format |
|------|----|--------|
| A guide in `guides/` | Another guide in `guides/` | `[Other Guide](other-guide.md)` |
| A file in `examples/` | A guide in `guides/` | `[Guide Name](../guides/guide-name.md)` |
| Root files (README, CONTRIBUTING) | A guide in `guides/` | `[Guide Name](guides/guide-name.md)` |
| Root files | An example in `examples/` | `[Example](examples/example-name.md)` |
| A guide in `guides/` | An example in `examples/` | `[Example](../examples/example-name.md)` |

## Adding a New Guide

1. Create a new Markdown file in `guides/` following the naming convention: lowercase, hyphen-separated (e.g., `my-new-topic.md`).
2. Write the guide following the style guide above.
3. Add an entry to the appropriate category table in `README.md` (Fundamentals, Workflows, Advanced Topics, Cost and Efficiency, or Reference).
4. Add a "See Also" section at the bottom of your new guide with 3-4 links to related guides.
5. Update the "See Also" sections in those related guides to link back to your new guide. Cross-links should be bidirectional.

### New guide template

````markdown
# Guide Title

Brief introduction to the topic (1-2 sentences).

## Section One

Content here.

## Section Two

Content here.

## See Also

- [Getting Started](guides/getting-started.md) -- Initial setup and first run
- [CLAUDE.md Guide](guides/claude-md-guide.md) -- Writing project instructions
- [Prompt Tips](guides/prompt-tips.md) -- Communicating effectively with Claude
````

## Adding a New Example

1. Create a new Markdown file in `examples/` following the naming convention: lowercase, hyphen-separated (e.g., `claude-md-django.md` or `hook-scripts.md`).
2. Include practical, copy-pasteable content that readers can adapt to their own projects.
3. Add an entry to the Examples table in `README.md`.
4. Link back to the relevant guide from within the example file (e.g., an example CLAUDE.md should reference `guides/claude-md-guide.md`).

## PR Process

### One topic per PR

Each pull request should focus on a single topic: one new guide, one bug fix, or one set of related improvements. This keeps reviews focused and makes the git history useful.

### PR body

Describe what you changed and why. For new guides, briefly explain the topic and why it belongs in the wiki. For fixes, reference the issue number if one exists.

### Reviewer checklist

Reviewers verify the following before merging:

- All internal links resolve to existing files
- Content follows the style guide (headings, code blocks, line count, no emojis)
- Information is accurate and actionable
- "See Also" links are bidirectional (new guide links to related guides, related guides link back)
- The README.md table of contents is updated

### Before submitting

- Run the link checker if one is available to verify all relative links are valid.
- Read through your changes one more time to catch typos and formatting issues.
- Confirm that any new files are listed in the README.md tables.

## Questions?

If you are unsure about where a guide belongs, how to structure content, or whether a topic is in scope, open an issue to discuss it before writing.
