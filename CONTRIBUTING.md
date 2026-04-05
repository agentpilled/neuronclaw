# Contributing to NeuronClaw

Thanks for your interest in improving NeuronClaw! Here's how to contribute.

## How NeuronClaw Works

NeuronClaw is an OpenClaw skill — it's pure markdown, no executable code. The
agent reads the skill files and follows the procedures using OpenClaw's built-in
tools. This means contributions are primarily documentation and procedural
improvements.

## What You Can Contribute

- **Better detection heuristics** — Improve when the agent decides to capture a task
- **New security patterns** — Add threat patterns to the scanner
- **Worked examples** — Real-world before/after skill creation stories
- **Rule refinements** — Better scope guards, naming conventions, complexity triggers
- **Bug fixes** — Incorrect procedures, broken cross-references, unclear instructions
- **Translations** — Translate docs (not the skill itself) to other languages

## Contribution Process

1. Fork the repository
2. Create a feature branch: `git checkout -b improve-detection-heuristics`
3. Make your changes
4. Ensure all cross-references in SKILL.md still resolve
5. Submit a pull request with a clear description of what changed and why

## Guidelines

- **Keep SKILL.md short** — It's a dispatcher. Put detailed procedures in `references/`.
- **Be specific** — Write procedures the agent can follow mechanically. Avoid vague guidance.
- **Test mentally** — Walk through the full lifecycle with your change. Does it break anything?
- **One concern per file** — Each reference doc covers one capability. Don't merge concerns.
- **Templates must be valid** — YAML frontmatter in templates must parse correctly.

## File Organization

| Directory | Purpose | Who reads it |
|-----------|---------|-------------|
| `references/` | Detailed procedures | The agent (loaded on-demand) |
| `rules/` | Decision rules | The agent (loaded on-demand) |
| `assets/templates/` | File templates | The agent (copied when creating) |
| `assets/examples/` | Worked examples | The agent (for reference) |
| `examples/` | Community walkthroughs | Humans |
| `docs/` | Extended documentation | Humans |

## Questions?

Open an issue. We're happy to help.
