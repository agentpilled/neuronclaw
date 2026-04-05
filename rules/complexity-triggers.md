---
name: complexity-triggers
description: Thresholds and heuristics for assessing task complexity in NeuronClaw skill detection.
---

# Complexity Triggers

## Scoring Scale (1–10)

| Score | Description | Example |
|-------|------------|---------|
| 1 | Single command, obvious | `npm install express` |
| 2 | 2–3 commands, no decisions | Create a file, write content, save |
| 3 | Multi-step but linear, no branching | Set up a git repo, add remote, push |
| 4 | Multiple tools, one decision point | Deploy app, choosing between two config options |
| 5 | Multi-tool, error handling needed | Set up CI that requires debugging config issues |
| 6 | Cross-domain coordination | Frontend + backend + database changes for one feature |
| 7 | Significant debugging required | Tracing a bug across multiple services |
| 8 | Novel approach discovered | Finding a workaround for an undocumented limitation |
| 9 | Complex orchestration | Multi-service deployment with rollback strategy |
| 10 | Breakthrough solution | Novel technique combining multiple approaches |

## Automatic Triggers

These automatically qualify a task for detection evaluation (complexity >= 5):

- **5+ tool calls** in the task
- **Error recovery:** At least one failed attempt before success
- **Multi-file changes:** Modified 3+ files as part of one coherent task
- **Long chain:** Task required more than 10 minutes of agent work
- **User said "that was tricky"** or similar acknowledgment of difficulty

## Bonus Modifiers

Apply these after the base score:

| Condition | Modifier |
|-----------|----------|
| Error recovery involved | +2 |
| Workaround for known bug/limitation | +1 |
| Cross-platform considerations | +1 |
| Security-sensitive operation | +1 |
| User explicitly praised the approach | +1 |

Cap at 10 after modifiers.

## Minimum Threshold

**Complexity >= 4 required for drafting.**

Tasks scoring 1–3 are too simple to justify the overhead of a draft. The
exception is tasks that are "easy to get wrong" (see scope-guard.md), which
can be bumped to 4 with justification.
