---
name: detection
description: Heuristics and decision tree for evaluating whether a completed task is worth capturing as a NeuronClaw draft.
---

# Task Detection: Is This Skill-Worthy?

After completing a task, run through this evaluation before moving on.

## Step 0: Quick Disqualifiers

Stop here if ANY of these are true:
- The task took fewer than 3 distinct steps
- You used fewer than 5 tool calls total
- The task is a one-off personal request (e.g., "write me a birthday message")
- An existing skill or draft already covers this approach (check with `qmd`)
- The task is trivially documented ("run npm install", "git push")
- The fix is specific to one bug in one codebase with no generalizable pattern

If none of the disqualifiers apply, continue to Step 1.

## Step 1: Complexity Assessment

Rate the task on a 1–10 complexity scale:

| Score | Criteria |
|-------|----------|
| 1–3 | Single tool, no decisions, obvious approach |
| 4–5 | Multiple tools, one decision point, straightforward but multi-step |
| 6–7 | Multiple tools, error recovery needed, non-obvious approach |
| 8–9 | Cross-domain (files + network + shell), significant debugging, workflow discovery |
| 10 | Novel approach, combined multiple techniques, hard-won knowledge |

**Minimum threshold: complexity >= 4.** Below this, skip drafting.

## Step 2: Reusability Check

Ask yourself:
1. Could this approach apply to a different project or context?
2. Would a different person benefit from these steps?
3. Did you discover something non-obvious (a flag, a workaround, an ordering)?

If you answered "no" to all three, skip drafting.

If you answered "yes" to at least one, continue to Step 3.

## Step 3: Novelty Check

Search for existing coverage:
1. Run `qmd search` against `$AGENT_HOME/neuronclaw/drafts/` with keywords from the task
2. Run `qmd search` against `$AGENT_HOME/neuronclaw/skills/` with the same keywords
3. If a close match exists with similarity > 80%, this is a **match**, not a new draft:
   - Update the existing draft's `match_count` and `last_matched`
   - Append any new steps or caveats discovered
   - Check if promotion criteria are now met
   - Stop here

If no close match exists, proceed to drafting. Load
[./drafting.md](./drafting.md) for the capture procedure.

## Step 4: Error Recovery Bonus

If the task involved recovering from errors (failed commands, wrong approaches,
retries), the approach is especially valuable. Bump the complexity score by +2
(capped at 10) because error recovery knowledge is the hardest to rediscover.

## Decision Tree Summary

```
Task completed
  │
  ├─ Quick disqualifier? ──▶ SKIP
  │
  ├─ Complexity < 4? ──▶ SKIP
  │
  ├─ Not reusable? ──▶ SKIP
  │
  ├─ Existing draft/skill matches?
  │   ├─ Yes ──▶ UPDATE match_count, check promotion
  │   └─ No ──▶ CREATE new draft
  │
  └─ Error recovery involved? ──▶ Bump complexity +2
```

## What Counts as a "Tool Call"

For the 5+ tool call threshold:
- Each file read, write, or edit = 1 call
- Each shell command = 1 call
- Each web search or fetch = 1 call
- Each browser action = 1 call
- Sub-agent delegations count as the number of tools the sub-agent used
- Memory operations (read/write) do NOT count — they're infrastructure, not task work
