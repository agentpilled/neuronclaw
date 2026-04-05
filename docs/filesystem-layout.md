# Filesystem Layout

All NeuronClaw state lives under `$AGENT_HOME/neuronclaw/`. This directory is
created lazily on first activation.

## Directory Tree

```
$AGENT_HOME/neuronclaw/
│
├── drafts/                          # Candidate approaches
│   ├── deploy-nextjs-flyio.md       # Each draft is one markdown file
│   ├── setup-ci-github-actions.md
│   └── fix-postgres-migration.md
│
├── skills/                          # Promoted, active skills
│   ├── deploy-nextjs-flyio/         # Each skill is a directory
│   │   └── SKILL.md                 # Standard OpenClaw skill format
│   └── setup-ci-github-actions/
│       └── SKILL.md
│
├── metadata/                        # Per-skill tracking
│   ├── deploy-nextjs-flyio.yaml     # One YAML file per skill
│   └── setup-ci-github-actions.yaml
│
├── archive/                         # Retired items (never deleted)
│   ├── drafts/                      # Drafts that expired or were promoted
│   │   └── fix-postgres-migration.md
│   └── skills/                      # Skills that were deprecated or merged
│       └── deploy-react-vercel/
│           └── SKILL.md
│
└── reports/                         # Garbage collection reports
    ├── gc-2026-04-05.md             # One per GC run
    └── gc-2026-04-12.md             # Max 10 retained
```

## File Formats

### Drafts (`drafts/{slug}.md`)

Markdown with YAML frontmatter. Contains: context, steps, caveats, key
decisions, and origin session info. See
[assets/templates/draft.md](../assets/templates/draft.md).

### Skills (`skills/{slug}/SKILL.md`)

Standard OpenClaw skill format with YAML frontmatter. Contains: when to use,
prerequisites, procedure, caveats, troubleshooting. See
[assets/templates/skill.md](../assets/templates/skill.md).

### Metadata (`metadata/{slug}.yaml`)

YAML tracking file. Contains: status, usage counts, success/failure rates,
patch count, security scan results, usage log. See
[assets/templates/metadata.yaml](../assets/templates/metadata.yaml).

### Reports (`reports/gc-{YYYY-MM-DD}.md`)

Markdown report from garbage collection runs. Contains: summary stats, actions
taken, items needing attention, recommendations. See
[assets/templates/review-report.md](../assets/templates/review-report.md).

## Naming Convention

All slugs follow `{action}-{subject}-{context}` pattern in lowercase with
hyphens. See [rules/naming-conventions.md](../rules/naming-conventions.md).

## Storage Characteristics

- **All text-based** — no binary files, no databases
- **Human-readable** — browse with `ls`, read with `cat`, edit with any text editor
- **Git-friendly** — the entire directory can be version-controlled if desired
- **Portable** — copy the directory to move your skill library between machines
- **No external dependencies** — state is self-contained, no network calls needed
