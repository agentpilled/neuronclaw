---
name: scope-guard
description: Rules for what should NOT be captured as a NeuronClaw draft — edge cases and grey areas.
---

# Scope Guard: What Not to Skill-ify

The inline scope guard in SKILL.md covers the basics. This document covers
edge cases.

## Hard Rules (Never Create Drafts For)

1. **Trivial tasks** — Fewer than 3 distinct steps, or complexity < 4
2. **One-off requests** — "Write a poem about cats", "Summarize this article"
3. **Already covered** — An existing skill or draft handles this (check with `qmd`)
4. **Documented procedures** — If the steps are "follow the official docs", link the docs instead
5. **Bug-specific fixes** — A fix for one specific bug in one codebase, with no generalizable pattern
6. **NeuronClaw meta-operations** — Never skill-ify NeuronClaw's own procedures (no circular self-improvement)
7. **Credentials or secrets** — Any task whose value is in the specific credentials used

## Grey Areas (Use Judgment)

### "I followed a tutorial"
- If you just followed a tutorial step by step → NOT skill-worthy (link the tutorial)
- If you followed a tutorial but had to adapt 3+ steps for the user's specific setup → Skill-worthy (the adaptations are the value)

### "It was complex but very domain-specific"
- If the complexity came from the domain (e.g., specific API quirks) → Skill-worthy (domain knowledge is valuable)
- If the complexity came from bad docs/tooling that will likely be fixed → Probably NOT skill-worthy (the skill will be outdated soon)

### "The user asked me to remember this"
- If the user says "remember how to do this" → Capture as a draft regardless of complexity (user intent overrides scope guard)
- If the user says "save this as a skill" → Promote directly to probation skill (skip draft phase)

### "It's simple but I keep doing it wrong"
- If a task is simple (complexity 2–3) but you've failed at it before → Capture it. The complexity score doesn't capture "easy to get wrong" tasks.
- Bump the complexity to 4 with a note: "Low step count but error-prone"

### "It worked but I'm not sure it's the best approach"
- Capture it as a draft. If a better approach emerges later, the draft can be updated or superseded.
- Do NOT wait for the "perfect" approach — drafts are cheap.

## Scope Expansion (When to Be More Generous)

Be more willing to capture drafts when:
- The user is working in a new domain (more things are non-obvious)
- Error recovery was involved (hard-won knowledge)
- Multiple tools were coordinated (orchestration patterns are valuable)
- The task involved a workaround for a known limitation

## Scope Contraction (When to Be More Strict)

Be less willing to capture drafts when:
- The skill library already has 15+ active skills (noise risk increases)
- The user hasn't used existing skills recently (suggests they don't find them valuable)
- The task is in a rapidly changing domain (skills will go stale quickly)
