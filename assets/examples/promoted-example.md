---
name: deploy-nextjs-flyio
description: >
  Deploy a Next.js application to Fly.io using a multi-stage Docker build
  for minimal image size. Use when the user asks to deploy a Next.js app
  to Fly.io or needs to set up Fly.io deployment for a Next.js project.
metadata:
  tags: [deployment, fly.io, nextjs, docker, multi-stage]
  created_by: neuronclaw
  promoted_from: draft-deploy-nextjs-flyio
  version: 1.0.0
---

# Deploy Next.js to Fly.io

## When to Use

- User asks to deploy a Next.js application to Fly.io
- User needs to set up Fly.io deployment for an existing Next.js project
- User wants to optimize their Next.js Docker image for Fly.io

## Prerequisites

- `flyctl` CLI installed and authenticated (`fly auth whoami` succeeds)
- A Next.js application with `package.json` in the project root
- A Fly.io account (free tier works)

## Procedure

1. Initialize Fly.io app (skip if `fly.toml` already exists):
   ```bash
   fly launch --no-deploy --name {app_name} --region {region}
   ```

2. Enable standalone output in `next.config.js`:
   ```js
   /** @type {import('next').NextConfig} */
   const nextConfig = {
     output: 'standalone',
   }
   module.exports = nextConfig
   ```
   **Important:** This must be set before building.

3. Create a multi-stage `Dockerfile` at project root:
   - **Stage 1 (deps):** `node:20-alpine`, install dependencies only
   - **Stage 2 (builder):** Copy source, run `npm run build`
   - **Stage 3 (runner):** `node:20-alpine`, copy `.next/standalone` + `.next/static` + `public/`
   - Set `HOSTNAME=0.0.0.0` and expose port 3000
   - Expected final image size: ~180MB

4. Configure `fly.toml` for the app:
   ```toml
   [http_service]
     internal_port = 3000
     force_https = true
   [http_service.concurrency]
     type = "connections"
     hard_limit = 25
     soft_limit = 20
   ```

5. Set environment variables (if any):
   ```bash
   fly secrets set DATABASE_URL="{database_url}" NODE_ENV="production"
   ```

6. Deploy:
   ```bash
   fly deploy --ha=false
   ```

7. Verify:
   ```bash
   fly status
   fly open
   ```

## Caveats

- `output: 'standalone'` must be configured BEFORE `npm run build`
- Use `--ha=false` for single-machine deployment (cost-effective for small apps)
- If using native Node modules, switch from `node:20-alpine` to `node:20-slim`
- Set secrets BEFORE first deploy to avoid a broken initial deployment

## Troubleshooting

**If build fails with "cannot find module" errors:**
Check that all dependencies are in `dependencies`, not just `devDependencies`,
since the standalone build only includes production deps.

**If health check fails after deploy:**
Verify `internal_port` in `fly.toml` matches the port in your Dockerfile
(`EXPOSE 3000` and `PORT=3000`).

**If cold starts are slow (>5s):**
Ensure you're using the multi-stage Dockerfile (not the default Node builder).
Check image size with `fly image show` — it should be under 200MB.
