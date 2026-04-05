# Before & After: Deployment Workflow

## Before NeuronClaw

Every time the user asks to deploy a Next.js app to Fly.io, the agent:

1. Figures out the approach from scratch
2. May or may not remember the multi-stage Dockerfile trick
3. Might forget to set `output: 'standalone'` before building
4. Might use Alpine and hit native module issues again
5. Takes 10–15 minutes each time

**Each deployment is independent.** The agent doesn't learn from past deployments.

## After NeuronClaw

**First deployment:** Agent works through the problem (12 tool calls, 15 min).
NeuronClaw captures a draft.

**Second deployment:** Agent solves it again. NeuronClaw detects the match,
promotes to skill.

**Third deployment onward:** Agent loads the skill and follows it. Takes 5
minutes. Includes all the caveats discovered in previous deployments (Alpine
vs slim, standalone mode timing, secret-setting order).

**After a failure:** The skill self-patches. The fix is preserved for all
future deployments.

**After 2 months:** Similar deploy skills are consolidated into one
parametrized skill covering multiple platforms.

## The Numbers

| Metric | Before | After |
|--------|--------|-------|
| Time per deployment | 10–15 min | 5 min |
| Errors repeated | Same mistakes | Patched away |
| Knowledge retained | None | In the skill |
| Skills maintained | N/A | Automated |
