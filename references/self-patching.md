---
name: self-patching
description: Procedure for detecting and fixing broken or outdated NeuronClaw-generated skills during use.
---

# Self-Patching: Fixing Skills During Use

You're following a NeuronClaw-generated skill and something is wrong. Fix it now.

## When to Patch

Patch immediately if you encounter ANY of these during skill execution:
- A command fails because syntax or flags changed
- A step references a file, path, or URL that no longer exists
- A prerequisite is missing from the Prerequisites section
- The order of steps is wrong (step 3 depends on something not done until step 5)
- A caveat is missing that you just discovered the hard way
- The skill works but there's a clearly better approach for one of the steps

## When NOT to Patch (Redraft Instead)

If more than 50% of the steps need changing, this isn't a patch — the skill is
fundamentally wrong. In this case:

1. Set the skill's metadata status to `deprecated`
2. Record the failure in `usage_log`
3. Treat the current task as a new draft opportunity (go through
   [detection.md](./detection.md) and [drafting.md](./drafting.md))
4. Inform the user: "Skill '{name}' was too outdated to patch. Deprecated it
   and captured a fresh draft."

## Patching Procedure

### Step 1: Identify the Problem

Before changing anything, clearly state:
- Which step failed
- What the expected behavior was
- What actually happened
- What the fix is

### Step 2: Apply the Fix

Edit `$AGENT_HOME/neuronclaw/skills/{slug}/SKILL.md`:
- Fix the specific step, command, or section
- If adding a new caveat, add it to the Caveats section
- If adding a troubleshooting entry, add it to the Troubleshooting section
- Preserve the rest of the skill unchanged

### Step 3: Update Metadata

Edit `$AGENT_HOME/neuronclaw/metadata/{slug}.yaml`:
- Increment `patch_count`
- Add to `usage_log`:
  ```yaml
  - date: YYYY-MM-DD
    outcome: patched
    notes: "Brief description of what was fixed and why"
  ```

### Step 4: Run Security Scan

After patching, scan the modified skill per [./security.md](./security.md).
If the patch introduced a security concern (even accidentally), revert the
change and try again.

### Step 5: Continue Execution

Resume following the skill from where you left off, using the patched version.
Don't restart from step 1 unless the patch changes the entire flow.

### Step 6: Brief the User

> "Patched skill '{name}': {one-line description of fix}."

Keep it to one line. The user doesn't need the full story unless they ask.

## Patch Size Limits

| Patch scope | Action |
|-------------|--------|
| 1–2 steps changed | Normal patch |
| 3–4 steps changed | Patch, but note in metadata: "significant patch" |
| 5+ steps or >50% changed | Deprecate and redraft (see "When NOT to Patch") |

## Version Tracking

NeuronClaw doesn't version skills formally (no v1.0.1 bumps). Instead:
- `patch_count` in metadata tracks how many times the skill has been modified
- `usage_log` entries with `outcome: patched` provide the full history
- If a skill has been patched 5+ times, it may indicate the domain is too
  volatile for a static skill — consider whether it should be archived

## Patching During Probation

If a skill in `probation` status needs patching:
- The patch resets `consecutive_successes` to 0
- The failure that triggered the patch counts toward `consecutive_failures`
- After patching, the next successful use starts a fresh success streak
- This means a patched probation skill needs 3 *more* successes to stabilize
