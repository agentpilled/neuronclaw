---
name: garbage-collection
description: Procedure for reviewing, archiving, and cleaning up NeuronClaw drafts and skills.
---

# Garbage Collection: Keeping the Skill Library Clean

A skill library that only grows eventually drowns the agent in noise. GC keeps
it sharp.

## When to Run GC

### On-Demand (Primary Mode)
- The user explicitly asks: "review my skills", "clean up NeuronClaw", "run GC"
- You notice the total skill count exceeds 20 (check during any NeuronClaw operation)
- After promoting a new skill (good time to check for similar existing skills)

### Cron-Based (Optional)
If the user wants automated cleanup, schedule a weekly cron job via OpenClaw:
- **Job name:** `neuronclaw-gc`
- **Schedule:** Weekly (suggest Sunday night or during dreaming cycle)
- **Prompt:** "Load the NeuronClaw skill and run garbage collection per references/garbage-collection.md"

## GC Procedure

### Step 1: Inventory

Read all files in:
- `$AGENT_HOME/neuronclaw/drafts/` → list all drafts with their frontmatter
- `$AGENT_HOME/neuronclaw/metadata/` → list all skill metadata files
- Count totals: drafts, probation skills, stable skills, deprecated skills

### Step 2: Flag Expired Drafts

For each draft in `drafts/`:
- Calculate age: `today - created`
- If `age > 30 days` AND `match_count < 2` → flag for archival
  - **Reason:** "Draft expired — no repeated pattern in 30 days"

### Step 3: Flag Deprecated Skills

For each skill with `status: deprecated` in metadata:
- Calculate time since deprecation (infer from last status change in usage_log)
- If deprecated for 30+ days → flag for archival
  - **Reason:** "Deprecated skill unused for 30+ days"

### Step 4: Flag Low-Quality Skills

For each skill with `status: stable` or `status: probation`:
- Compute quality score per [./scoring.md](./scoring.md)
- If `quality < 0.3` → flag for review
  - **Reason:** "Quality score {score} below threshold (0.3)"
- If `status: probation` AND `consecutive_failures >= 2` → flag for review
  - **Reason:** "Probation skill with 2+ consecutive failures"

### Step 5: Flag Unused Stable Skills

For each skill with `status: stable`:
- Calculate days since `last_used`
- If `last_used` is more than 60 days ago → change status to `deprecated`
  - **Reason:** "Stable skill unused for 60+ days"
- Do NOT archive immediately — give the user 30 more days to use it

### Step 6: Consolidation Pass

Load [./consolidation.md](./consolidation.md) and check for mergeable skills.
This is the most valuable part of GC — it turns many weak skills into fewer
strong ones.

### Step 7: Generate Report

Create a report at `$AGENT_HOME/neuronclaw/reports/gc-{YYYY-MM-DD}.md` using
the template at [../assets/templates/review-report.md](../assets/templates/review-report.md).

Include:
- Date and summary stats
- Actions taken (archived, deprecated, consolidated)
- Skills that need user attention
- Recommendations

### Step 8: Execute Actions

For each flagged item:

**Archiving a draft:**
1. Move `drafts/{slug}.md` → `archive/drafts/{slug}.md`
2. Add to frontmatter: `archived_on: {today}`, `archived_reason: expired`

**Archiving a skill:**
1. Move `skills/{slug}/` → `archive/skills/{slug}/`
2. Update metadata: `status: archived`
3. Add to usage_log: `{ date: today, outcome: archived, notes: "{reason}" }`

**Deprecating a skill:**
1. Update metadata: `status: deprecated`
2. Add to usage_log: `{ date: today, outcome: deprecated, notes: "{reason}" }`

### Step 9: Report to User

Summarize what GC did:

> "NeuronClaw GC complete. Archived {n} expired drafts, deprecated {n} unused
> skills, consolidated {n} similar skills. {n} skills need your attention.
> Full report at neuronclaw/reports/gc-{date}.md"

## Dependency Check

Before archiving any skill, check if other skills reference it:
1. Search all skills in `$AGENT_HOME/neuronclaw/skills/` for the slug
2. If referenced by another active skill, do NOT archive
3. Instead, flag it: "Cannot archive — referenced by {other_skill}"

## GC Report Retention

Keep the last 10 GC reports. When creating report #11, delete the oldest.
Reports are for audit trail, not permanent record.

## Adaptive Thresholds

Default thresholds (draft expiry: 30d, stable→deprecated: 60d, etc.) are
starting points. During each GC run, analyze actual usage patterns and adjust:

### How to Adapt

1. **Draft promotion speed:** Look at all promoted drafts. If the median time
   from draft creation to promotion is 5 days (not 30), lower the expiry to
   3x the median (15 days). Formula:
   ```
   new_draft_expiry = max(7, median_promotion_days * 3)
   ```

2. **Skill usage frequency:** If the median time between skill uses is 14 days,
   the 60-day stable→deprecated threshold is generous. Adjust to:
   ```
   new_stable_expiry = max(30, median_usage_gap * 4)
   ```

3. **Quality threshold:** If most skills score above 0.6, the 0.3 archive
   threshold is too lenient. Adjust to:
   ```
   new_quality_threshold = max(0.2, median_quality * 0.5)
   ```

### Where to Store Adapted Values

Write adapted thresholds to `$AGENT_HOME/neuronclaw/config.yaml`:
```yaml
thresholds:
  draft_expiry_days: 15        # default: 30
  stable_expiry_days: 45       # default: 60
  quality_archive_threshold: 0.35  # default: 0.3
  last_adapted: "YYYY-MM-DD"
```

If `config.yaml` doesn't exist, use defaults. The agent updates it during GC.

### Guardrails

- Never set `draft_expiry_days` below 7 (need at least a week to re-encounter)
- Never set `stable_expiry_days` below 30 (skills need breathing room)
- Never set `quality_archive_threshold` above 0.5 (too aggressive)
- Include `last_adapted` date to prevent adjusting every GC run
- Only adapt if there are at least 5 data points (promoted drafts or skill uses)

## Manual Overrides

The user can always:
- Manually archive any skill: "Archive the {name} skill"
- Manually restore from archive: "Restore {name} from NeuronClaw archive"
- Skip GC for specific skills: "Keep {name} even though it's unused"
- Override thresholds: "Set draft expiry to 14 days"

User instructions always take precedence over GC automation and adaptive
thresholds.
