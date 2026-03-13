---
name: deploy-with-vercel
description: Deploy applications to Vercel. Use when the user says "deploy", "deploy to Vercel", "push to production", "deploy my app", or "go live".
---

# Deploy to Vercel

## Prerequisites Check

```bash
vercel --version
```

If not installed: `npm install -g vercel`

Check if logged in:
```bash
vercel whoami
```

If not logged in: `vercel login`

## Deployment

Default to **preview** deployment, which gives a publicly accessible URL that doesn't require the viewer to authenticate:

```bash
vercel
```

If the user explicitly asks for a production deployment:
```bash
vercel --prod
```

## After Deployment

- Display the deployment URL
- Show build status
- Mention `vercel logs <url>` for debugging if needed
