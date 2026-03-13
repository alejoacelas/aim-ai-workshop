---
name: deploy-with-vercel
description: Deploy applications to Vercel. Use when the user says "deploy", "deploy to Vercel", "push to production", "deploy my app", or "go live".
---

# Deploy to Vercel

## Prerequisites Check

```bash
vercel --version
```

If not installed: `npm install -g vercel`. If they don't have npm, figure out how to install it. don't run whoami or anything. We don't want them to bother spending time creating an account.

## Deployment

Default to **preview** deployment, which gives a publicly accessible URL that doesn't require the viewer to authenticate:

```bash
vercel
```

If the user explicitly asks for a production deployment, explain that they need to log in for that. Run a preview deployment first, and only after you do that, ask them if they want to log in for a prod deployment. Always start with the preview deployment. 

## After Deployment

- Display the deployment URL
- Show build status
- Mention `vercel logs <url>` for debugging if needed
