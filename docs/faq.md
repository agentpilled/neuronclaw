# FAQ

## General

### What is NeuronClaw?

NeuronClaw is a skill for OpenClaw that teaches your agent to learn from its
own work. It autonomously captures complex task approaches, validates them
over repeated use, and promotes proven patterns to reusable skills.

### How is this different from OpenClaw's built-in memory?

OpenClaw's memory system (MEMORY.md, USER.md, daily notes) stores *facts* —
what you told it, what it learned about you. NeuronClaw stores *procedures* —
how to do things. Memory is "you prefer dark mode." NeuronClaw is "here's
how to deploy a Next.js app to Fly.io."

### Does it work with any LLM?

Yes. NeuronClaw is pure markdown — it works with any LLM that OpenClaw
supports. The quality of the generated skills depends on the LLM's capability,
but the format and lifecycle work with any model.

### Will it slow down my agent?

No. SKILL.md is ~150 lines. Reference documents are loaded on-demand only when
a trigger fires. If NeuronClaw doesn't activate, it costs almost nothing in
context.

## Skill Lifecycle

### Why drafts instead of creating skills directly?

Most tasks feel important in the moment but never recur. The draft system
prevents skill bloat by requiring a pattern to prove itself (2+ matches) before
committing to a real skill. Without this, you'd end up with hundreds of
one-use skills.

### How does the agent know when a pattern repeats?

After completing a task, the agent searches existing drafts using `qmd`
(OpenClaw's semantic search tool). If a draft matches the current task's
approach with >70% similarity, it's counted as a repeat.

### Can I manually promote a draft?

Yes. Tell your agent: "Promote the {name} draft to a skill." This skips
the match_count requirement and goes directly to probation.

### Can I manually create a skill?

Yes. Tell your agent: "Save this as a NeuronClaw skill." This skips the
draft phase entirely and creates a skill in probation.

### What happens during probation?

Each use is tracked as success or failure. After 3 consecutive successes,
the skill becomes stable. After 2 consecutive failures (with a patch attempt
in between), it's deprecated.

## Maintenance

### How does garbage collection work?

GC reviews all drafts and skills, archiving stale items and flagging
low-quality ones. It runs on-demand ("run NeuronClaw GC") or optionally
via weekly cron.

### Are archived skills deleted?

No. Archived items are moved to `neuronclaw/archive/` but never deleted.
This preserves the record of what was tried. You can restore archived
skills manually.

### What if a skill breaks?

If a skill produces wrong results during use, NeuronClaw patches it
immediately (self-patching). If more than 50% of steps need changing,
it deprecates the skill and captures a fresh draft instead.

### Can I edit skills manually?

Yes. Skills are standard markdown files. Edit them with any text editor.
NeuronClaw won't overwrite your manual changes (but the next self-patch
may modify the skill further).

## Security

### Is it safe to let the agent create skills?

NeuronClaw scans every generated skill for 5 threat categories (data
exfiltration, destructive commands, credential harvesting, prompt injection,
privilege escalation) before activation. Critical findings block the skill.

### Can a skill modify NeuronClaw itself?

No. NeuronClaw has a hard rule against creating skills that modify its own
management files. This prevents circular self-modification.

### What if the security scanner has false positives?

Skills can declare an allowlist for expected patterns (like legitimate API
calls). The user must approve each allowlist entry. The scanner is
intentionally conservative — false positives are preferable to false negatives.

## Troubleshooting

### NeuronClaw isn't capturing my tasks

Check:
1. Was the task complex enough? (complexity >= 4, usually 5+ tool calls)
2. Is there already a draft or skill covering it? (NeuronClaw deduplicates)
3. Does it pass the scope guard? (see rules/scope-guard.md)

### I have too many drafts

Run garbage collection: "Run NeuronClaw GC." Drafts older than 30 days
without repeated matches are automatically archived.

### A skill keeps failing

If a skill fails repeatedly despite patching, it may be in a volatile domain.
Consider archiving it manually and relying on direct problem-solving instead.
