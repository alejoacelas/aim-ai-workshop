---
name: deploy-with-vercel
description: Deploy applications to Vercel. Use when the user says "deploy", "deploy to Vercel", "push to production", "deploy my app", or "go live".
---

# Deploy to Vercel

**Always deploy as preview** (not production) unless the user explicitly asks for production. Preview deployments give a publicly accessible URL—no Vercel account needed to view them.

## Prerequisites

Check whether the Vercel CLI is installed **without** escalated permissions:

```bash
command -v vercel
```

If not installed: `npm install -g vercel`

## Deployment

Use the `-y` flag to accept defaults (no interactive prompts) and a **10-minute timeout** (600000ms) since builds can take a while:

```bash
vercel deploy [path] -y
```

If the CLI fails with "No existing credentials found" or an auth error, help the user log in with `vercel login`.

## Production deploys

Only if the user explicitly asks:

```bash
vercel deploy [path] --prod -y
```

## After deployment

- Display the deployment URL
- **Do not** curl or fetch the deployed URL to verify it works—just return the link
- Mention `vercel logs <url>` for debugging if needed

## Troubleshooting

### Network/sandbox issues

If deployment fails due to network issues (timeouts, DNS errors, connection resets), rerun the deploy command with escalated permissions (`dangerouslyDisableSandbox=true`). Only escalate the actual deploy command, not the installation check.
