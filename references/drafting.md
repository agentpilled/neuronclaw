---
name: drafting
description: Step-by-step procedure for capturing a completed task as a NeuronClaw draft.
---

# Drafting: Capturing a Task as a Draft

You've determined a task is skill-worthy (via [detection.md](./detection.md)).
Now capture it before the context leaves your window.

## Step 1: Generate the Slug

Create a slug from the task's core action:
- Lowercase, hyphens only: `deploy-nextjs-flyio`, `fix-postgres-migration`, `setup-ci-github-actions`
- Max 64 characters
- Must be unique across drafts and skills (check `$AGENT_HOME/neuronclaw/drafts/` and `skills/`)
- See [naming conventions](../rules/naming-conventions.md) for detailed rules

## Step 2: Extract the Approach

From your recent session, extract:

### Context
- What was the user trying to accomplish?
- What were the starting conditions?
- What tools/services were involved?

### Steps
- List every step you took, in order
- Include the actual commands, file paths, and configurations used
- Note which steps were essential vs. optional
- Mark any steps that required error recovery

### Caveats
- What went wrong before it went right?
- What prerequisites aren't obvious?
- What platform-specific gotchas exist?
- What would you do differently next time?

### Key Decisions
- Where did you choose between alternatives?
- Why did you pick the approach you picked?
- What tradeoffs were involved?

## Step 3: Generalize

Replace specific values with descriptive placeholders:
- `/Users/john/myapp` → `{project_root}`
- `my-app-name` → `{app_name}`
- `postgres://localhost:5432/mydb` → `{database_url}`
- API keys, tokens, passwords → `{api_key}`, `{token}` (NEVER include real credentials)

Keep enough specificity that the steps are actionable. Over-generalization makes
skills useless. Under-generalization makes them too narrow.

**Good:** "Run `fly deploy --app {app_name} --dockerfile ./Dockerfile`"
**Too general:** "Deploy the application to the platform"
**Too specific:** "Run `fly deploy --app johns-nextjs-app --dockerfile ./Dockerfile`"

## Step 4: Write the Draft

Create the file at `$AGENT_HOME/neuronclaw/drafts/{slug}.md` using the template
at [../assets/templates/draft.md](../assets/templates/draft.md).

Fill in:
- **Frontmatter:** id, title, created (today), last_matched (today), match_count (1),
  origin_task (brief description), tags (3–7 relevant tags), complexity (from detection),
  status ("draft")
- **Context section:** When this approach applies
- **Steps section:** Numbered, imperative, specific steps
- **Caveats section:** Warnings, prerequisites, gotchas
- **Origin Session section:** Task description, date, key decisions

## Step 5: Verify

Before saving, check:
- [ ] No real credentials, API keys, or personal data in the draft
- [ ] Steps are ordered correctly (could someone follow them top to bottom?)
- [ ] Caveats cover the errors you encountered
- [ ] Tags are relevant and would help `qmd` find this draft later
- [ ] Complexity score matches the assessment from detection
- [ ] The slug is unique

## Step 6: Confirm to User

After saving, briefly tell the user:
> "Captured '{title}' as a NeuronClaw draft. It will be promoted to a skill
> if this pattern comes up again."

Keep it short. Don't explain the full lifecycle unless asked.

## What NOT to Capture

Even if a task passes detection, skip drafting if:
- The approach depends on a temporary state that won't exist next time
- The steps are just "read the docs and follow them" (link the docs instead)
- The task was completed by trial-and-error with no clear repeatable procedure
- More than 50% of the steps are "wait for X" with no actionable guidance
