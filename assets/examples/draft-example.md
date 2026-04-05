---
id: draft-deploy-nextjs-flyio
title: "Deploy Next.js App to Fly.io"
created: 2026-03-20
last_matched: 2026-03-20
match_count: 1
origin_task: "Deployed user's Next.js 14 app to Fly.io with Docker multi-stage build"
tags: [deployment, fly.io, nextjs, docker, multi-stage]
complexity: 7
status: draft
---

## Context

When the user needs to deploy a Next.js application to Fly.io. The app uses
the App Router, has API routes, and needs a production Docker image. The key
challenge is keeping the Docker image small while supporting all Next.js
features (standalone output mode).

## Steps

1. Verify `flyctl` is installed and authenticated
   ```bash
   fly version
   fly auth whoami
   ```

2. Check if `fly.toml` exists. If not, create one:
   ```bash
   fly launch --no-deploy --name {app_name} --region {region}
   ```

3. Configure `next.config.js` for standalone output:
   ```js
   /** @type {import('next').NextConfig} */
   const nextConfig = {
     output: 'standalone',
   }
   module.exports = nextConfig
   ```

4. Create a multi-stage Dockerfile:
   - Stage 1 (`deps`): Install dependencies only
   - Stage 2 (`builder`): Build the app with standalone output
   - Stage 3 (`runner`): Copy only the standalone output + static assets
   - Use `node:20-alpine` for all stages
   - Final image should be ~180MB instead of ~1.2GB

5. Update `fly.toml` with health check and environment:
   ```toml
   [http_service]
     internal_port = 3000
     force_https = true
   [http_service.concurrency]
     type = "connections"
     hard_limit = 25
     soft_limit = 20
   ```

6. Deploy:
   ```bash
   fly deploy --ha=false
   ```

7. Verify deployment:
   ```bash
   fly status
   fly open
   ```

## Caveats

- `output: 'standalone'` must be set BEFORE building — changing it after build has no effect
- The `--ha=false` flag prevents Fly from creating multiple machines (saves cost on small apps)
- If the app uses environment variables, set them with `fly secrets set KEY=value` BEFORE deploying
- Alpine-based Node images may fail if native modules are used (use `node:20-slim` instead)

## Key Decisions

- Chose multi-stage Docker over Fly's built-in Node builder: 6x smaller image, faster cold starts
- Used `--ha=false` for single-machine deployment: user is on the hobby plan

## Origin Session

- **Task:** "Help me deploy my Next.js app to Fly"
- **Date:** 2026-03-20
- **Key insight:** The multi-stage Dockerfile reduced image from 1.2GB to 180MB, cutting cold start from ~8s to ~2s
