---
name: scoring
description: How to track skill usage, compute quality scores, and report on skill effectiveness.
---

# Scoring: Tracking Skill Quality

Every NeuronClaw skill has a quality score. This document covers how to track
usage, compute scores, and report on skill health.

## Recording Usage

After every skill execution, update `$AGENT_HOME/neuronclaw/metadata/{slug}.yaml`:

### On Success

```yaml
use_count: {+1}
success_count: {+1}
consecutive_successes: {+1}
consecutive_failures: 0        # reset
last_used: {today}
usage_log:
  - date: {today}
    outcome: success
    notes: "Brief context"
```

### On Failure

```yaml
use_count: {+1}
failure_count: {+1}
consecutive_failures: {+1}
consecutive_successes: 0       # reset
last_used: {today}
usage_log:
  - date: {today}
    outcome: failure
    notes: "What went wrong and why"
```

### On Patch

See [self-patching.md](./self-patching.md). Patches get their own log entry
with `outcome: patched`.

### Determining Success vs Failure

A skill execution is a **success** if:
- All steps completed without manual intervention or deviation
- The end result matched what the skill promised
- No steps needed modification during execution

A skill execution is a **failure** if:
- One or more steps failed and required workarounds NOT in the skill
- The skill had to be abandoned midway
- The end result was wrong despite following the skill

A skill execution that required a **patch** counts as a failure for the
current use, but the patch may prevent future failures.

## Computing Quality Score

The quality score is computed on demand — never cached. This prevents stale
scores from driving bad decisions.

### Formula

```
quality = success_rate * 0.5
        + usage_factor * 0.3
        + recency_factor * 0.2

Where:
  success_rate   = success_count / max(use_count, 1)
  usage_factor   = min(use_count / 10, 1.0)
  recency_factor = based on days since last_used:
                   0–7 days   → 1.0
                   8–30 days  → 0.5
                   31–90 days → 0.2
                   91+ days   → 0.0
```

### Interpretation

| Score | Health | Action |
|-------|--------|--------|
| >= 0.7 | Healthy | No action needed |
| 0.4–0.69 | Needs attention | Review for patching opportunities |
| < 0.4 | Unhealthy | Candidate for archival or major rewrite |

### Example Calculations

**Skill A:** 8 uses, 7 successes, used 3 days ago
```
quality = (7/8)*0.5 + min(8/10,1)*0.3 + 1.0*0.2
        = 0.4375 + 0.24 + 0.2
        = 0.8775  → Healthy
```

**Skill B:** 4 uses, 2 successes, used 45 days ago
```
quality = (2/4)*0.5 + min(4/10,1)*0.3 + 0.2*0.2
        = 0.25 + 0.12 + 0.04
        = 0.41  → Needs attention
```

**Skill C:** 2 uses, 0 successes, used 100 days ago
```
quality = (0/2)*0.5 + min(2/10,1)*0.3 + 0.0*0.2
        = 0.0 + 0.06 + 0.0
        = 0.06  → Unhealthy (archive candidate)
```

## Reporting

When the user asks about skill health, generate a report:

### Individual Skill Report

```
Skill: {name}
Status: {status}
Quality: {score}/1.0 ({interpretation})
Uses: {use_count} ({success_count} success, {failure_count} failure)
Last used: {last_used} ({days} days ago)
Patches: {patch_count}
```

### Full Portfolio Report

```
NeuronClaw Skill Report — {date}
================================

Drafts: {count}
Skills: {count} ({stable} stable, {probation} probation, {deprecated} deprecated)
Archived: {count}

Top Skills (by quality):
  1. {name} — {score} ({use_count} uses)
  2. {name} — {score} ({use_count} uses)
  3. {name} — {score} ({use_count} uses)

Needs Attention:
  - {name} — {score} (reason: {low success / not used recently / etc.})

Candidates for Archival:
  - {name} — {score} (reason)
```

## Usage Log Maintenance

The `usage_log` array in metadata can grow indefinitely. To prevent bloat:
- Keep the most recent 20 entries
- When adding entry 21, remove the oldest entry
- The aggregate counters (`use_count`, `success_count`, etc.) remain accurate
  regardless of log trimming
