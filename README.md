# Coding agents 101

Workshop materials for getting started with AI coding agents (Claude Code or Codex).

## What's here

- **`content/`** — Workshop guide sections in markdown. This is the source of truth for the [live guide](https://claude.ai/install.sh).
- **`site/`** — Static webpage that renders the guide. Serve with `npx serve .` from the project root, then open `http://localhost:3000/site/`.
- **`skills/`** — Reusable agent skills participants install during the workshop.
- **`helpme/`** — Support tool: a shell script + Cloudflare worker that helps participants troubleshoot installation issues.
- **`install-homebrew.sh`** — Homebrew install helper referenced in the guide.

## Running the guide locally

```
npx serve .
# Open http://localhost:3000/site/
```
