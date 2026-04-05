# Consolidation Example

## Before: Two Separate Skills

### Skill 1: `deploy-nextjs-flyio`
Steps: configure standalone → multi-stage Dockerfile → fly.toml → fly deploy

### Skill 2: `deploy-nextjs-railway`
Steps: configure standalone → multi-stage Dockerfile → railway.json → railway up

**Overlap analysis:** 70%+ of steps identical (standalone config, Dockerfile
structure, verification). Only deployment target config differs.

## After: One Consolidated Skill

### `deploy-nextjs` (consolidated)

```markdown
---
name: deploy-nextjs
description: >
  Deploy a Next.js application to a cloud platform (Fly.io or Railway)
  using an optimized multi-stage Docker build.
metadata:
  tags: [deployment, nextjs, docker, fly.io, railway]
  created_by: neuronclaw
  version: 1.0.0
---

# Deploy Next.js

## When to Use

User asks to deploy a Next.js application to Fly.io or Railway.

## Prerequisites

- Next.js application with `package.json` in project root
- Target platform CLI installed:
  - **Fly.io:** `flyctl` installed and authenticated
  - **Railway:** `railway` CLI installed and authenticated

## Procedure

1. Enable standalone output in `next.config.js`:
   [... same steps for both platforms ...]

2. Create multi-stage Dockerfile:
   [... same steps for both platforms ...]

3. Configure deployment target:

   **If deploying to Fly.io:**
   - Create `fly.toml` with internal_port 3000
   - Set secrets: `fly secrets set KEY=value`
   - Deploy: `fly deploy --ha=false`

   **If deploying to Railway:**
   - Create `railway.json` with build settings
   - Set variables: `railway variables set KEY=value`
   - Deploy: `railway up`

4. Verify deployment:
   **Fly.io:** `fly status && fly open`
   **Railway:** `railway status && railway open`
```

## Metadata After Consolidation

```yaml
slug: "deploy-nextjs"
status: stable
use_count: 8           # sum: 5 (flyio) + 3 (railway)
success_count: 7       # sum: 4 + 3
failure_count: 1       # sum: 1 + 0
```

## What Happened to the Originals

Both `deploy-nextjs-flyio` and `deploy-nextjs-railway` were moved to
`archive/skills/` with frontmatter noting `consolidated_into: deploy-nextjs`.
