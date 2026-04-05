---
name: forking
description: Procedure for creating variant skills from existing ones without modifying the original.
---

# Forking: Experimenting Without Risk

Fork a skill to try a different approach while keeping the proven original
intact. Think of it as a git branch for skills.

## When to Fork

- You want to try an alternative approach for a task an existing skill covers
- The user says "try it differently this time" or "use X instead of Y"
- A skill works but you suspect a significantly better approach exists
- The user asks to "fork" or "branch" a skill

## When NOT to Fork (Patch Instead)

- The change is small (1-2 steps) → use self-patching
- The original skill is broken → patch or deprecate it
- You're just adding a caveat or troubleshooting entry → patch

## Fork Procedure

### Step 1: Choose a Name

The fork slug should indicate its relationship to the original:
- Original: `deploy-nextjs-flyio`
- Fork: `deploy-nextjs-kamal` (different approach)
- Fork: `deploy-nextjs-flyio-monorepo` (specialization)

Follow [../rules/naming-conventions.md](../rules/naming-conventions.md).

### Step 2: Copy the Original

```
$AGENT_HOME/neuronclaw/skills/{original_slug}/SKILL.md
  → copy to →
$AGENT_HOME/neuronclaw/skills/{fork_slug}/SKILL.md
```

### Step 3: Update the Fork's Frontmatter

```yaml
name: {fork_slug}
description: >
  {Updated description reflecting the variant approach}
metadata:
  tags: {original tags + new ones}
  created_by: neuronclaw
  forked_from: {original_slug}
  version: 1.0.0
```

### Step 4: Modify the Fork

Make the changes that differentiate this variant. The fork is a full skill —
change whatever needs changing.

### Step 5: Create Metadata

Create `$AGENT_HOME/neuronclaw/metadata/{fork_slug}.yaml`:
- `status`: `probation` (forks always start in probation)
- `forked_from`: `{original_slug}`
- All counters at 0

### Step 6: Link the Skills

Update the original's metadata to track the fork:
```yaml
related_skills: [{fork_slug}]
```

Update the fork's metadata:
```yaml
related_skills: [{original_slug}]
```

### Step 7: Confirm

> "Forked '{original}' → '{fork}' (probation). Both skills remain active.
> The fork needs 3 successful uses to stabilize."

## Fork Lifecycle

Forks follow the normal skill lifecycle (probation → stable). Additionally:

**If the fork outperforms the original:**
- Fork quality > original quality for 5+ uses
- Propose consolidation: the fork replaces the original
- Archive the original with `superseded_by: {fork_slug}`

**If the fork underperforms:**
- Normal deprecation rules apply (2 consecutive failures → deprecated)
- The original is unaffected

**If both are valuable:**
- They coexist as separate skills for different contexts
- Consider if they should be consolidated into one parametrized skill

## Fork Limits

- Max 2 active forks per original skill (to prevent fragmentation)
- If a third fork is needed, first consolidate or archive existing forks
- Forks of forks are not allowed — fork from the original only
