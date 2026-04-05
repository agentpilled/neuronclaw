---
name: naming-conventions
description: How to name NeuronClaw drafts, skills, slugs, and files consistently.
---

# Naming Conventions

## Slugs (Draft and Skill Identifiers)

Slugs are the primary identifier for drafts and skills.

**Format:** `lowercase-with-hyphens`

**Rules:**
- Max 64 characters
- Only lowercase letters, numbers, and hyphens
- Must start with a letter
- No consecutive hyphens (`deploy--app` → `deploy-app`)
- No trailing hyphens

**Pattern:** `{action}-{subject}-{context}`

| Component | Purpose | Examples |
|-----------|---------|---------|
| Action | What the skill does | `deploy`, `fix`, `setup`, `migrate`, `configure` |
| Subject | What it acts on | `nextjs`, `postgres`, `docker`, `ci` |
| Context | Where/how (optional) | `flyio`, `github-actions`, `monorepo` |

**Good slugs:**
- `deploy-nextjs-flyio`
- `setup-ci-github-actions`
- `fix-postgres-migration`
- `configure-docker-multistage`

**Bad slugs:**
- `my-skill` (not descriptive)
- `fix-the-thing-that-broke` (too vague)
- `DeployNextJS` (not lowercase-hyphens)
- `a` (too short to be meaningful)

## Draft Files

**Location:** `$AGENT_HOME/neuronclaw/drafts/{slug}.md`
**ID in frontmatter:** `draft-{slug}`

## Skill Directories

**Location:** `$AGENT_HOME/neuronclaw/skills/{slug}/SKILL.md`
**Name in frontmatter:** `{slug}` (no prefix)

## Metadata Files

**Location:** `$AGENT_HOME/neuronclaw/metadata/{slug}.yaml`
**Slug field:** `{slug}` (matches the skill directory name)

## Archive Files

**Drafts:** `$AGENT_HOME/neuronclaw/archive/drafts/{slug}.md`
**Skills:** `$AGENT_HOME/neuronclaw/archive/skills/{slug}/SKILL.md`

## Reports

**Location:** `$AGENT_HOME/neuronclaw/reports/gc-{YYYY-MM-DD}.md`
**If multiple GC runs on same day:** `gc-{YYYY-MM-DD}-2.md`

## Tags

Tags in frontmatter and metadata:
- Lowercase
- Single words or hyphenated compounds: `deployment`, `error-handling`, `ci-cd`
- 3–7 tags per skill
- Prefer established terms over invented ones
