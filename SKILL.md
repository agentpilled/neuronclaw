---
name: neuronclaw
description: >
  Self-improvement engine for OpenClaw agents. Autonomously captures complex task
  approaches as drafts, validates them over repeated use, promotes proven patterns
  to reusable skills, and manages the full lifecycle — patching, scoring, security
  scanning, and garbage collection. Activate after completing complex tasks, when
  reviewing skill health, or when a skill produces wrong results during use.
metadata:
  tags: self-improvement, skill-creation, meta-learning, automation, lifecycle
  version: 1.0.0
---

# NeuronClaw

An agent that never learns from its work is doing the same work twice.
NeuronClaw teaches you to capture what works, discard what doesn't, and
build a library of skills that grows sharper over time — automatically.

## Storage Layout

All NeuronClaw state lives under `$AGENT_HOME/neuronclaw/`. Create this tree
lazily on first activation if it doesn't exist:

```
$AGENT_HOME/neuronclaw/
├── drafts/          # Candidate approaches not yet promoted
├── skills/          # Promoted, active skills (each in its own subdirectory)
├── archive/         # Retired drafts and deprecated skills
│   ├── drafts/
│   └── skills/
├── metadata/        # Per-skill YAML tracking files
└── reports/         # GC review reports
```

## When to Activate

### 1. After completing a complex task

**Trigger:** You just finished a task that involved 5+ tool calls, required error
recovery, or followed a multi-step workflow.

**Action:** Load [./references/detection.md](./references/detection.md) to evaluate
whether the task is skill-worthy. If yes, load
[./references/drafting.md](./references/drafting.md) to capture it as a draft.

### 2. When a draft's pattern repeats

**Trigger:** You completed a task and `qmd` search against existing drafts found
a semantically similar draft with `match_count >= 1`.

**Action:** Increment the draft's `match_count`. If promotion criteria are met,
load [./references/promotion.md](./references/promotion.md) to promote it.

### 3. When a skill produces wrong results during use

**Trigger:** You are following a NeuronClaw-generated skill and a step is wrong,
outdated, or incomplete.

**Action:** Load [./references/self-patching.md](./references/self-patching.md).
Patch the skill immediately — don't wait to be asked. Skills that aren't
maintained become liabilities.

### 4. When reviewing skill health

**Trigger:** The user asks to review skills, run garbage collection, or a
scheduled cron cycle fires.

**Action:** Load [./references/garbage-collection.md](./references/garbage-collection.md)
and [./references/consolidation.md](./references/consolidation.md).

### 5. Before executing any NeuronClaw-generated skill for the first time

**Trigger:** You are about to use a skill from `$AGENT_HOME/neuronclaw/skills/`
that has never been executed before (check metadata `use_count`).

**Action:** Load [./references/security.md](./references/security.md) and scan
the skill before execution.

### 6. When querying skill effectiveness

**Trigger:** The user asks about skill quality, usage stats, or "how are my skills doing."

**Action:** Load [./references/scoring.md](./references/scoring.md) to compute
and report quality scores.

## Scope Guard

Do NOT create drafts for:
- Tasks with fewer than 3 distinct steps
- One-off personal requests that won't recur
- Work already covered by an existing skill or draft (check with `qmd` first)
- Trivially documented procedures (e.g., "run npm install")
- Bug fixes specific to one codebase with no generalizable pattern
- Anything about NeuronClaw's own operation (no circular self-improvement)

For edge cases, load [./rules/scope-guard.md](./rules/scope-guard.md).

## Quick Reference: File Formats

### Draft frontmatter

```yaml
---
id: draft-{slug}
title: "Short descriptive title"
created: YYYY-MM-DD
last_matched: YYYY-MM-DD
match_count: 1
origin_task: "Brief description of the original task"
tags: [tag1, tag2]
complexity: 7          # 1-10 scale
status: draft
---
```

### Metadata file (YAML)

```yaml
slug: skill-slug
status: probation      # probation | stable | deprecated | archived
promoted_on: YYYY-MM-DD
last_used: YYYY-MM-DD
use_count: 0
success_count: 0
failure_count: 0
patch_count: 0
consecutive_successes: 0
consecutive_failures: 0
tags: []
usage_log: []
```

### Quality score (compute on demand, never cache)

```
quality = (success_count / max(use_count, 1)) * 0.5
        + min(use_count / 10, 1.0) * 0.3
        + recency_factor * 0.2

recency_factor: 7d = 1.0, 30d = 0.5, 90d = 0.2, else 0.0
```

`>= 0.7` healthy | `0.4–0.7` needs attention | `< 0.4` archive candidate

## Status Lifecycle

```
draft ──[match_count >= 2, age >= 24h, complexity >= 4]──> probation
probation ──[3 consecutive successes]──────────────────────> stable
probation ──[2 consecutive failures + patch attempt]───────> deprecated
stable ──[unused 60 days]──────────────────────────────────> deprecated
deprecated ──[unused 30 more days]─────────────────────────> archived
```

## Initialization

On first activation, if `$AGENT_HOME/neuronclaw/` does not exist:

1. Create the full directory tree shown in Storage Layout
2. Confirm to the user: "NeuronClaw initialized at $AGENT_HOME/neuronclaw/"
3. Optionally offer to schedule weekly GC via cron

After initialization, proceed with the triggered action.
