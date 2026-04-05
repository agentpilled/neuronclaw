# NeuronClaw Architecture

## Design Philosophy

NeuronClaw is a **pure markdown skill** — it contains zero executable code.
Everything works by instructing the agent through procedural documentation that
it follows using OpenClaw's built-in tools (file I/O, shell, `qmd` search, cron).

This is intentional:
- **No runtime dependencies** — nothing to install, update, or break
- **Full transparency** — every decision the agent makes is traceable through readable files
- **Portable** — works with any OpenClaw-compatible agent, regardless of LLM backend
- **Safe** — the agent uses its normal tools, with its normal permission model

## Component Overview

```
┌─────────────────────────────────────────────────────┐
│                     SKILL.md                         │
│              (dispatcher — ~150 lines)               │
│                                                      │
│  Triggers:                                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ Complex  │ │  Pattern │ │  Skill   │            │
│  │  task    │ │  repeats │ │  broken  │            │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘            │
│       │             │            │                   │
│       ▼             ▼            ▼                   │
│  ┌─────────┐  ┌──────────┐ ┌───��──────┐            │
│  │detection│  │promotion │ │  self-   │  ...more   │
│  │+ draft  │  │          │ │ patching │  triggers  │
│  └─────────┘  └──────────┘ └──────────┘            │
│  (references loaded on demand)                      │
└─────────────────────────────────��───────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────┐
│              $AGENT_HOME/neuronclaw/                 │
│                 (filesystem state)                   │
│                                                      │
│  drafts/     skills/     metadata/     archive/     │
│  (candidates) (active)   (tracking)   (retired)     │
└────────────────────────────────────��────────────────┘
```

## How the Dispatcher Works

SKILL.md is intentionally short. It defines **when** each capability activates
and **where** to find the detailed procedure. The agent loads only the reference
document it needs for the current operation.

This matters because:
- Loading all 8 reference docs at once would consume ~15K tokens of context
- Most operations only need 1–2 reference docs (~2–4K tokens)
- The dispatcher pattern keeps NeuronClaw lightweight when installed but inactive

## Data Flow: Task to Stable Skill

```
1. Agent completes task
   │
2. SKILL.md trigger #1 fires
   │
3. Agent loads detection.md
   │  Evaluates: complexity >= 4? reusable? novel?
   │
4. Agent loads drafting.md
   │  Extracts approach, generalizes, writes draft file
   │
5. [Later] Same pattern appears
   │  SKILL.md trigger #2 fires
   │
6. Agent loads promotion.md
   │  Checks: match_count >= 2? age >= 24h? security scan passes?
   │  Creates skill directory + metadata file
   │
7. Skill is in "probation"
   │  Each use updates metadata (success/failure)
   │
8. After 3 consecutive successes → "stable"
```

## State Management

All state is filesystem-based:

| State | Format | Location |
|-------|--------|----------|
| Drafts | Markdown with YAML frontmatter | `neuronclaw/drafts/{slug}.md` |
| Skills | Standard OpenClaw SKILL.md format | `neuronclaw/skills/{slug}/SKILL.md` |
| Metadata | YAML | `neuronclaw/metadata/{slug}.yaml` |
| Archive | Same as originals | `neuronclaw/archive/{drafts,skills}/` |
| Reports | Markdown | `neuronclaw/reports/gc-{date}.md` |

There is no database, no binary state, no hidden configuration. A user can
browse the entire system with `ls` and `cat`.

## Security Model

NeuronClaw generates skills that contain shell commands, file operations, and
potentially network calls. The security scanner (references/security.md) checks
every generated skill against 5 threat categories before it can be promoted
or executed.

The scanner is **conservative by default** — it blocks on critical findings
and flags warnings for user review. Skills can declare an allowlist for
expected patterns (like API calls), but the user must approve each entry.

**Hard constraint:** NeuronClaw cannot create skills that modify its own
management files. This prevents circular self-modification attacks.

## Garbage Collection Model

Skills have a lifecycle: `draft → probation → stable → deprecated → archived`.

GC runs on-demand or via cron and handles:
- **Expired drafts:** No repeated pattern in 30 days → archived
- **Failed probation:** 2+ consecutive failures → deprecated
- **Stale skills:** Unused for 60 days → deprecated → archived after 30 more days
- **Low quality:** Score < 0.3 → flagged for review
- **Consolidation:** Similar skills merged into parametrized versions

The archive is never deleted — it serves as a record of what was tried and why
it didn't stick.

## Integration with OpenClaw

NeuronClaw uses these OpenClaw capabilities:
- **File I/O:** Reading/writing drafts, skills, metadata, reports
- **Shell:** Running commands referenced in skills
- **`qmd`:** Semantic search for draft/skill matching and consolidation
- **Cron (optional):** Scheduling weekly garbage collection
- **Memory:** NeuronClaw does NOT write to OpenClaw's memory system — it maintains its own state

NeuronClaw does NOT use:
- Custom code execution
- External APIs or services
- Database connections
- OpenClaw's plugin SDK
