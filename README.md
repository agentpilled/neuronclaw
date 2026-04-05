# NeuronClaw

> The self-improving skill engine for OpenClaw agents.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![OpenClaw Skill](https://img.shields.io/badge/OpenClaw-Skill-orange)](https://github.com/agentpilled/neuronclaw)

An agent that never learns from its work is doing the same work twice.

**NeuronClaw** teaches your OpenClaw agent to learn from experience. When your
agent solves a complex problem, NeuronClaw captures the approach, validates it
over repeated use, promotes proven patterns to reusable skills, and manages the
full lifecycle — all automatically.

Inspired by [Hermes Agent](https://github.com/NousResearch/hermes-agent)'s
autonomous skill creation, rebuilt from the ground up for OpenClaw's
markdown-native skill system.

## How It Works

```
                    ┌─────────────────────────────────────────────┐
                    │            NeuronClaw Lifecycle              │
                    └─────────────────────────────────────────────┘

  Complex Task               Draft                      Skill
  Completed            (candidate approach)        (proven pattern)
       │                      │                         │
       ▼                      ▼                         ▼
  ┌─────────┐  capture   ┌─────────┐  promote   ┌───────────┐
  │ Detect  │──────────▶│  Draft  │───────────▶│ Probation │
  └─────────┘            └─────────┘            └───────────┘
       │                      │                      │
       │ not worthy           │ no repeat            │ 3 successes
       ▼                      ▼                      ▼
    (skip)              (auto-archive           ┌─────────┐
                         after 30d)             │ Stable  │
                                                └─────────┘
                                                     │
                                                     │ unused 60d
                                                     ▼
                                                ┌────────────┐
                                                │ Deprecated │──▶ Archived
                                                └────────────┘
```

### The Anti-Bloat Pipeline

Most skill systems drown in low-quality entries. NeuronClaw prevents this:

1. **Detect** — After complex tasks (5+ tool calls, error recovery, multi-step
   workflows), NeuronClaw evaluates if the approach is worth remembering
2. **Draft** — Captures the approach as a *draft*, not a skill. Drafts are
   candidates, not commitments
3. **Validate** — When the same pattern appears again (2+ matches), the draft
   has proven itself
4. **Promote** — Validated drafts become real skills with a probation period
5. **Maintain** — Skills are scored, patched when broken, archived when stale
6. **Secure** — Every skill is scanned for dangerous patterns before activation

## Features

- **Autonomous skill creation** from complex task completions
- **Draft-before-promote pipeline** prevents skill bloat
- **Self-healing** — broken skills are patched during use, not after
- **Quality scoring** with weighted formula (success rate, frequency, recency)
- **Garbage collection** archives stale skills, merges similar ones
- **Security scanner** catches data exfiltration, destructive commands, credential
  harvesting, prompt injection, and privilege escalation
- **Zero dependencies** — pure markdown, uses only OpenClaw's built-in tools
- **Transparent state** — everything stored as readable markdown and YAML files

## Installation

### From GitHub

Add to your `skills-lock.json`:

```json
{
  "neuronclaw": {
    "source": "agentpilled/neuronclaw",
    "sourceType": "github"
  }
}
```

### Manual

```bash
git clone https://github.com/agentpilled/neuronclaw.git
cp -r neuronclaw/ ~/.agents/skills/neuronclaw/
```

### First Run

No setup required. NeuronClaw initializes automatically the first time it
activates — creating its directory structure at `$AGENT_HOME/neuronclaw/`.

## Quick Start

1. **Install NeuronClaw** using one of the methods above
2. **Do complex work** — solve a multi-step problem, debug a tricky error, build
   a deployment workflow
3. **Watch NeuronClaw capture it** — after the task, your agent will evaluate the
   approach and save it as a draft
4. **Repeat the pattern** — next time a similar task appears, the draft gets
   promoted to a real skill
5. **Check your skills** — ask your agent: *"What skills has NeuronClaw captured?"*

## Storage Layout

All state lives on the filesystem — no databases, no opaque binary state:

```
$AGENT_HOME/neuronclaw/
├── drafts/          # Candidate approaches (markdown with YAML frontmatter)
├── skills/          # Promoted skills (each in its own subdirectory)
├── archive/         # Retired drafts and deprecated skills
├── metadata/        # Per-skill YAML tracking (usage, scores, history)
└── reports/         # Garbage collection review reports
```

## Quality Scoring

Every skill is scored on three dimensions:

| Weight | Dimension | What it measures |
|--------|-----------|-----------------|
| 50% | Success rate | `success_count / use_count` |
| 30% | Usage frequency | How often the skill is used (capped at 10) |
| 20% | Recency | When the skill was last used (decays over time) |

**Score >= 0.7** — Healthy skill, working well
**Score 0.4–0.7** — Needs attention, may need patching
**Score < 0.4** — Candidate for archival

## Security

NeuronClaw scans every generated skill for 5 threat categories before activation:

| Category | Examples |
|----------|---------|
| Data exfiltration | `curl` to external URLs, piping secrets to network commands |
| Destructive commands | `rm -rf`, `DROP DATABASE`, device writes |
| Credential harvesting | Reading `~/.ssh/`, `~/.aws/`, browser stores |
| Prompt injection | "Ignore previous instructions", encoded payloads |
| Privilege escalation | `sudo`, modifying `/etc/`, creating user accounts |

Skills with critical findings are blocked. Warnings are flagged for human review.

## How It Compares

| Feature | NeuronClaw | Hermes Agent | Vanilla OpenClaw |
|---------|-----------|-------------|-----------------|
| Autonomous skill creation | Yes | Yes | No |
| Draft-before-promote | Yes | No | N/A |
| Self-patching | Yes | Yes | No |
| Security scanning | Yes | Yes | No |
| Quality scoring | Yes | No | No |
| Garbage collection | Yes | No | No |
| Skill consolidation | Yes | No | No |
| RL training pipeline | No | Yes | No |
| Pure markdown (no runtime) | Yes | No (Python) | N/A |

## Configuration

NeuronClaw works out of the box with sensible defaults. All thresholds are
documented in the reference files and can be adjusted by editing:

| Setting | Default | Where |
|---------|---------|-------|
| Min complexity for drafts | 4 | `rules/complexity-triggers.md` |
| Matches needed for promotion | 2 | `references/promotion.md` |
| Draft expiry | 30 days | `references/garbage-collection.md` |
| Stable→deprecated threshold | 60 days | `references/garbage-collection.md` |
| GC archive score threshold | 0.3 | `references/garbage-collection.md` |

## Documentation

- [Architecture](docs/architecture.md) — How NeuronClaw works internally
- [Filesystem Layout](docs/filesystem-layout.md) — Where files live
- [FAQ](docs/faq.md) — Common questions
- [Full Walkthrough](examples/walkthrough.md) — End-to-end lifecycle example

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). We welcome better detection heuristics,
new security patterns, worked examples, and rule refinements.

## License

[MIT](LICENSE)
