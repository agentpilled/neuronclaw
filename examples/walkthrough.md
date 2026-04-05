# NeuronClaw Walkthrough

A complete lifecycle example — from task completion to stable skill.

## Day 1: The First Task

**User:** "Deploy my Next.js app to Fly.io"

The agent works through the deployment: configures standalone output, writes a
multi-stage Dockerfile, creates `fly.toml`, sets secrets, deploys, verifies.
It takes 12 tool calls and involves one error recovery (Alpine image failed
with a native module, switched to slim).

**NeuronClaw activates (Trigger #1: complex task)**

The agent evaluates:
- Tool calls: 12 (>= 5 threshold)
- Error recovery: yes (+2 complexity bonus)
- Complexity score: 7
- Reusable? Yes — deploying Next.js to Fly.io is a common pattern
- Existing draft? No (`qmd` search returns nothing)

The agent captures a draft:

```
$AGENT_HOME/neuronclaw/drafts/deploy-nextjs-flyio.md
```

> "Captured 'Deploy Next.js to Fly.io' as a NeuronClaw draft. It will be
> promoted to a skill if this pattern comes up again."

## Day 5: The Pattern Repeats

**User:** "I need to deploy another Next.js app to Fly, this time for my SaaS"

The agent starts working. After the task, NeuronClaw activates again.

**NeuronClaw detects a match (Trigger #2: pattern repeats)**

`qmd` search against drafts returns `deploy-nextjs-flyio.md` with 85% similarity.

The agent updates the draft:
- `match_count`: 1 �� 2
- `last_matched`: today
- Adds a note about monorepo support (the SaaS app was in a monorepo)

**Promotion check:**
- match_count >= 2? Yes (2)
- complexity >= 4? Yes (7)
- age >= 24h? Yes (5 days old)
- Security scan? Running...
  - Found 1 warning: `fly deploy` command (legitimate deployment tool)
  - No critical findings
  - Scan: PASSED

**NeuronClaw promotes the draft:**

```
$AGENT_HOME/neuronclaw/skills/deploy-nextjs-flyio/SKILL.md   (created)
$AGENT_HOME/neuronclaw/metadata/deploy-nextjs-flyio.yaml     (created)
$AGENT_HOME/neuronclaw/archive/drafts/deploy-nextjs-flyio.md (archived)
```

> "Promoted 'Deploy Next.js to Fly.io' from draft to skill (probation).
> It needs 3 consecutive successful uses to become stable."

## Day 8: First Probation Use

**User:** "Deploy my portfolio site to Fly"

The agent recognizes this matches the new skill. It loads the skill and follows
the procedure step by step. Everything works.

**NeuronClaw records success:**

```yaml
# metadata/deploy-nextjs-flyio.yaml
use_count: 1
success_count: 1
consecutive_successes: 1
```

## Day 15: A Failure and a Patch

**User:** "Deploy this Next.js app to Fly — it uses sharp for image processing"

The agent follows the skill. Step 3 (multi-stage Dockerfile) uses
`node:20-alpine`. The build fails because `sharp` needs native binaries not
available on Alpine.

**NeuronClaw activates (Trigger #3: skill produces wrong results)**

The agent patches the skill immediately:
- Adds a caveat: "If using native modules (sharp, canvas, bcrypt), use
  `node:20-slim` instead of `node:20-alpine`"
- Adds a troubleshooting entry for the Alpine/native module issue

```yaml
# metadata update
use_count: 2
failure_count: 1
consecutive_failures: 1
consecutive_successes: 0  # reset
patch_count: 1
```

> "Patched skill 'deploy-nextjs-flyio': added guidance for native modules
> requiring slim base image instead of Alpine."

The agent then re-executes with the patched instructions. Deployment succeeds.

## Days 18–25: Recovery

Three more deployments, all successful. The patch fixed the gap.

```yaml
# metadata after day 25
use_count: 5
success_count: 4
failure_count: 1
consecutive_successes: 3  # hit the threshold!
status: stable            # promoted from probation
```

> The skill is now stable.

## Day 60: Garbage Collection

The user asks: "Review my NeuronClaw skills."

**NeuronClaw runs GC (Trigger #4):**

Inventory:
- 3 drafts (2 expired, 1 recent)
- 4 skills (2 stable, 1 probation, 1 deprecated)

Actions:
- Archived 2 expired drafts (no repeated pattern in 30+ days)
- Archived 1 deprecated skill (deprecated 35 days ago, unused)
- Found 2 similar skills: `deploy-nextjs-flyio` and `deploy-nextjs-railway`
  → Proposed consolidation into `deploy-nextjs`

Report generated at `neuronclaw/reports/gc-2026-05-30.md`.

> "NeuronClaw GC complete. Archived 2 expired drafts and 1 deprecated skill.
> Proposed consolidating 2 deployment skills — shall I merge them?"

**User:** "Yes, merge them."

NeuronClaw consolidates both skills into `deploy-nextjs` with conditional
sections for Fly.io vs Railway.

## The Result

After 60 days, the user has:
- 2 stable skills (proven, actively maintained)
- 1 probation skill (still earning trust)
- 0 draft bloat (expired drafts archived)
- A consolidated skill library instead of fragmented duplicates

The agent learned from its work, and the user never had to manually create
or maintain a single skill.
