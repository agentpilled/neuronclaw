---
name: promotion
description: Criteria and step-by-step process for promoting a NeuronClaw draft to a full skill.
---

# Promotion: Draft to Skill

A draft has proven itself. Time to graduate it to a real skill.

## Promotion Criteria

ALL of these must be true:

1. **`match_count >= 2`** — The pattern has been useful at least twice
2. **`complexity >= 4`** — The task is non-trivial
3. **`age >= 24 hours`** — The draft has survived at least one day (prevents impulsive promotion)
4. **Security scan passes** — Load [./security.md](./security.md) and scan the draft content. No critical findings.

If any criterion is not met, update the draft (increment match_count if applicable)
and wait.

## Promotion Procedure

### Step 1: Security Scan

Before anything else, scan the draft content per [./security.md](./security.md).
If the scan finds critical issues, do NOT promote. Flag the draft and inform
the user.

### Step 1.5: Multi-Perspective Review

Evaluate the draft from four angles before promoting:

| Angle | Question | Pass if... |
|-------|----------|------------|
| **Security** | Could this skill cause harm if followed blindly? | No critical security findings |
| **Clarity** | Could a different agent follow these steps without ambiguity? | Steps are imperative, specific, and ordered |
| **Generalization** | Is this too specific to one context, or reusable? | At least 2 placeholders for variable values |
| **Maintainability** | Will this skill go stale quickly? | No hardcoded versions, URLs, or transient details |

If any angle scores poorly, patch the draft before promoting (fix the specific
issue). If the draft can't be fixed (e.g., inherently too specific), skip
promotion and leave it as a draft.

### Step 1.75: Approval Gate (Optional)

If the user has previously indicated they want manual approval before
promotions (check `$AGENT_HOME/neuronclaw/config.yaml` for `approval_mode: manual`),
ask before proceeding:

> "Draft '{title}' is ready for promotion (matched {match_count} times,
> complexity {complexity}). Promote to skill? [yes/no]"

If the user says no, leave the draft as-is. If `approval_mode` is `auto`
or not set, skip this step and promote automatically.

### Step 2: Create the Skill Directory

```
$AGENT_HOME/neuronclaw/skills/{slug}/
└── SKILL.md
```

### Step 3: Reformat the Draft as a Skill

Transform the draft into proper OpenClaw skill format:

```markdown
---
name: {slug}
description: >
  {One-line description derived from the draft title and context.
  This is what other agents/skills see when scanning available skills.}
metadata:
  tags: {tags from draft}
  created_by: neuronclaw
  promoted_from: draft-{slug}
  version: 1.0.0
---

# {Title}

## When to Use

{Extracted from the draft's Context section. Be specific about trigger conditions.}

## Prerequisites

{From the draft's Caveats — what must be true before starting.}

## Procedure

{The draft's Steps section, cleaned up:
- Numbered steps in imperative form
- Commands in code blocks
- Placeholders clearly marked with {braces}
- Error handling noted inline}

## Caveats

{Remaining warnings not covered by Prerequisites.}

## Troubleshooting

{If the draft included error recovery steps, document them here as
"If X happens, then Y" entries.}
```

### Step 4: Create Metadata

Create `$AGENT_HOME/neuronclaw/metadata/{slug}.yaml` using the template at
[../assets/templates/metadata.yaml](../assets/templates/metadata.yaml).

Initialize with:
- `slug`: the skill slug
- `status`: `probation`
- `promoted_on`: today's date
- `last_used`: null
- `use_count`: 0
- All counters at 0
- `tags`: copied from draft
- `usage_log`: empty array

### Step 5: Archive the Draft

Move the draft to `$AGENT_HOME/neuronclaw/archive/drafts/{slug}.md`.

Add to its frontmatter:
```yaml
promoted_on: YYYY-MM-DD
archived_reason: promoted
promoted_to: skills/{slug}
```

### Step 6: Confirm to User

> "Promoted '{title}' from draft to skill (probation). It needs 3 consecutive
> successful uses to become stable."

## Probation Rules

A skill in probation is tracked more carefully:

- **After each use:** Record outcome (success/failure) in metadata
- **3 consecutive successes** → Status changes to `stable`
- **Any failure** → Attempt a patch first (load [./self-patching.md](./self-patching.md))
- **2 consecutive failures after patching** → Status changes to `deprecated`

The probation period ensures that promoted skills actually work in practice,
not just in the original context where the draft was captured.

## Partial Matches

If a new task matches a draft at ~70% but has significant differences:

1. Update the existing draft with the new steps/caveats
2. Increment `match_count`
3. Note the variation in the draft body under a "## Variations" section
4. On promotion, the skill should include conditional steps:
   "If {condition}, use approach A. Otherwise, use approach B."

Do NOT create a separate draft for every minor variation of the same pattern.
