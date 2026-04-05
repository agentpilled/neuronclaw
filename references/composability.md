---
name: composability
description: How NeuronClaw skills can reference and chain other skills as sub-steps.
---

# Composability: Skills That Use Other Skills

Complex workflows often include sub-tasks that are skills in their own right.
Instead of duplicating steps, reference the sub-skill.

## How It Works

A skill can reference another skill as a sub-step in its Procedure section:

```markdown
## Procedure

1. Set up the project structure
   ```bash
   mkdir -p {project_root}/src
   ```

2. **→ Use skill: `setup-docker-multistage`**
   Load and follow the `setup-docker-multistage` skill from
   `$AGENT_HOME/neuronclaw/skills/setup-docker-multistage/SKILL.md`
   with these parameters:
   - `{base_image}` = `node:20-alpine`
   - `{build_command}` = `npm run build`

3. Configure deployment
   [... remaining steps ...]
```

## The `→ Use skill:` Convention

When the agent encounters a step starting with `→ Use skill:`, it should:

1. Check if the referenced skill exists in `$AGENT_HOME/neuronclaw/skills/`
2. If it exists: load it, follow its procedure, then return to the parent skill
3. If it doesn't exist: execute the step description as guidance (the parent
   skill should include enough context to proceed without the sub-skill)
4. Record the sub-skill usage in the sub-skill's metadata (counts as a use)

## Declaring Dependencies

Skills that depend on other skills should list them in their frontmatter:

```yaml
metadata:
  depends_on: [setup-docker-multistage, configure-ssl]
```

And in the generated metadata:
```yaml
related_skills: [setup-docker-multistage, configure-ssl]
```

## Rules

### Do Compose When:
- A sub-task appears in 3+ different skills (DRY principle)
- The sub-task is independently useful (has its own draft/skill lifecycle)
- The sub-task is complex enough to benefit from its own versioning/patching

### Don't Compose When:
- The "sub-skill" is 1-2 trivial steps (just inline them)
- The dependency creates a fragile chain (if sub-skill breaks, all parents break)
- The sub-task is tightly coupled to the parent context (not independently useful)

### Max Depth: 2
Skills can reference sub-skills, but sub-skills should NOT reference
sub-sub-skills. Two levels of nesting is the maximum. Beyond that, the
workflow is too complex for a markdown-based skill and should probably be
a Lobster pipeline or custom automation.

## Impact on Garbage Collection

When GC considers archiving a skill, it must check if other skills depend on it:

1. Search all active skills for `depends_on` references to the candidate
2. If any active skill depends on it: do NOT archive
3. Flag: "Cannot archive '{slug}' — used by {parent_skill_1}, {parent_skill_2}"

This is already covered in
[./garbage-collection.md](./garbage-collection.md) Step 8 (Dependency Check),
but composability makes it more common.

## Impact on Scoring

When a skill is used as a sub-skill:
- Its usage counts normally (use_count, success/failure, etc.)
- The parent skill's outcome does NOT cascade to the sub-skill
  - If the parent fails on step 5 but the sub-skill (step 2) succeeded,
    record success for the sub-skill and failure for the parent
- This prevents a single parent failure from unfairly degrading sub-skill scores

## Creating Composable Skills

When drafting, if you notice a sequence of steps that could be a standalone
skill:

1. Draft the sub-skill separately (it has its own lifecycle)
2. In the parent draft, reference it with `→ Use skill:` notation
3. Both drafts follow normal promotion independently
4. The composition link is established when both are promoted

Do NOT delay drafting the parent just because the sub-skill isn't promoted yet.
Use inline steps as fallback (see "If it doesn't exist" above).
