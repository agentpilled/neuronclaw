---
name: consolidation
description: Procedure for identifying and merging similar NeuronClaw skills into consolidated, parametrized versions.
---

# Consolidation: Merging Similar Skills

Three skills that each deploy to a different platform are better as one
parametrized skill. Consolidation reduces noise and increases coverage.

## When to Consolidate

- During garbage collection (Step 6)
- When you notice two skills with overlapping procedures during normal use
- When the user asks: "merge these skills", "consolidate my deploy skills"
- When promoting a new skill that is suspiciously similar to an existing one

## Finding Merge Candidates

### Step 1: Semantic Search

For each active skill in `$AGENT_HOME/neuronclaw/skills/`:
1. Extract the skill's title and first paragraph as a query
2. Run `qmd search` against all other active skills
3. If similarity > 70% between two skills, flag as potential merge candidates

### Step 2: Structural Comparison

For each candidate pair, compare:
- **Step overlap:** How many steps are identical or near-identical?
- **Step count ratio:** Are they similar in length?
- **Tag overlap:** Do they share most tags?
- **Caveat overlap:** Do they warn about the same things?

### Merge Criteria

Merge if ALL of these are true:
- 70%+ of steps are the same (with only parameter differences)
- The core approach is the same (not just superficially similar)
- A single parametrized skill would be clearer than two separate ones
- Neither skill would lose important nuance in the merge

Do NOT merge if:
- The skills look similar but solve fundamentally different problems
- Merging would create a confusing skill with too many conditionals
- One skill is a specialization that benefits from being standalone

## Merge Procedure

### Step 1: Identify Parameters

Compare the two skills side by side. Find where they differ:
- Different tool names → parameter: `{tool}`
- Different platform commands → parameter: `{platform}`
- Different configuration values → parameter: `{config_value}`

### Step 2: Create the Consolidated Skill

Write a new skill that:
- Uses parameters where the originals differed
- Includes conditional sections where approaches diverge:
  ```
  ## Step 3: Configure the deployment

  **If deploying to Fly.io:**
  - Create `fly.toml` with...

  **If deploying to Railway:**
  - Create `railway.json` with...
  ```
- Combines caveats from both originals
- Has a "When to Use" section that covers both original triggers

### Step 3: Name the Consolidated Skill

Use a broader name that encompasses both:
- `deploy-nextjs-flyio` + `deploy-nextjs-railway` → `deploy-nextjs`
- `setup-ci-github` + `setup-ci-gitlab` → `setup-ci`
- `fix-postgres-migration` + `fix-mysql-migration` → `fix-db-migration`

### Step 4: Create Metadata

Create new metadata for the consolidated skill:
- `status`: inherit the best status from the originals (`stable` > `probation`)
- `use_count`: sum of both originals
- `success_count`: sum of both originals
- `failure_count`: sum of both originals
- `promoted_on`: today
- `tags`: union of both tag sets
- Add to usage_log: `{ date: today, outcome: consolidated, notes: "Merged from {slug1} and {slug2}" }`

### Step 5: Archive the Originals

For each original skill:
1. Move to `archive/skills/{slug}/`
2. Update metadata: `status: archived`
3. Add to frontmatter: `consolidated_into: {new_slug}`, `archived_on: {today}`
4. Add to usage_log: `{ date: today, outcome: archived, notes: "Consolidated into {new_slug}" }`

### Step 6: Report

> "Consolidated '{skill_a}' and '{skill_b}' into '{new_skill}'. The original
> skills have been archived."

## Consolidation Limits

- Merge at most 3 skills at once. Beyond 3, the conditional logic becomes
  too complex.
- If a potential merge involves 4+ skills, look for natural groupings of 2–3
  and merge in stages.
- Never consolidate a skill that's currently in `probation` — let it stabilize
  first.

## When Consolidation Goes Wrong

If a consolidated skill performs worse than its originals (failures increase):
1. Restore the original skills from archive
2. Archive the consolidated skill
3. Note in metadata: "Consolidation reverted — {reason}"
4. The originals resume with their pre-consolidation metadata (status, counters)
