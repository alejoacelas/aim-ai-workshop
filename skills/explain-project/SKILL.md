# Explain what was built

You're helping a nonprofit founder understand what Claude Code just built for them. They're non-technical — they don't read code, but they're smart and want to understand what's running on their machine.

Your job: scan the project, then explain it clearly in plain language.

## Step 1: Scan the project

Use the Glob and Read tools to understand the full picture:
- Read every file Claude created or modified during this session
- Check `project-plan.md` if it exists — it describes what the founder wanted to build
- Look at any config files, scripts, HTML files, data files, etc.
- Note what external services are connected (Google Sheets, Slack, email, websites, etc.)

## Step 2: Write a plain-language explanation

Write the explanation to `what-we-built.md` using the structure below. Use everyday language — no code snippets, no jargon, no technical terms without explanation.

```markdown
# What we built

## In one sentence
[What this thing does, in terms the founder would use to describe it to a colleague]

## How it works
[Walk through what happens step by step, as if describing a Rube Goldberg machine to a friend. Use concrete nouns — "your Google Sheet," "an email," "the website" — not abstract ones like "the data source" or "the endpoint."]

[Number each step. Keep each step to 1-2 sentences.]

## What's connected
[List every external service, account, or tool this project touches, and what it does with each one. For example: "Google Sheets — reads your donor list from the 'Active Donors' tab."]

## How to run it
[Exact instructions to run the thing. Be specific: what to type, what to click, what to expect. If it runs automatically, say when and how.]

## What could go wrong
[2-3 realistic things that might break and what to do about each. For example: "If your Google Sheet gets renamed, the script won't find it. Fix: open the script and update the sheet name on line 3." Keep it practical, not exhaustive.]

## What you could add later
[2-3 natural extensions, described in terms of what they'd do for the founder, not how they'd be implemented. For example: "Send yourself a Slack message whenever the report is generated, so you don't have to remember to check."]
```

## Step 3: Open the file and walk them through it

After saving the file, open it so the founder can read along:
- On macOS: `open what-we-built.md`
- On Linux: `xdg-open what-we-built.md`
- On Windows: `start what-we-built.md`

Then give a brief conversational summary — 3-4 sentences max. Something like:

> "I've opened `what-we-built.md` for you — it's the full explanation of what we built. In short: [one-sentence summary]. It covers how it works step by step, how to run it, and what to do if something breaks."

## Tone

- Talk about what the *project* does, not what the *code* does. Say "it checks your inbox every morning" not "the cron job runs a Python script that calls the Gmail API."
- When you must reference a file, say what it does, not what it's called: "the main script" not "app.py."
- Don't explain programming concepts. They don't need to know what a function or a variable is.
- Be honest about limitations. If something is fragile, say so.
- Respect their intelligence — clear doesn't mean dumbed down.
