# Claude Code workshop for Charity Entrepreneurship founders

## What this is

I'm preparing a 2–3 hour workshop for Charity Entrepreneurship (CE) founders and some CE team members. The goal: introduce them to coding agents (specifically Claude Code) and have each person build something genuinely useful for their organization in about an hour of implementation time.

## Audience

- Non-technical. Most have never used Claude Code or similar tools.
- Extremely smart, resourceful people. Don't patronize or over-scaffold.
- They run young nonprofits (a few months to ~3 years old). They wear many hats—ops, fundraising, hiring, program design, government relations, partner coordination, reporting—everything a small org needs.
- Common domains across CE cohorts: global health, animal welfare, policy advocacy, mental health, family planning, lead exposure, and more. Don't anchor on any specific cause area—think about cross-cutting operational needs.

## Workshop structure (tentative)

1. ~20 min presentation: what are coding agents, how they work
2. Ideation: each person identifies something useful they could build
3. Planning: a step-by-step plan that flags which steps need human intervention (account creation, API keys, permissions) vs. which Claude Code handles autonomously
4. Building: ~1–1.5 hours of hands-on implementation
5. Wrap-up

I'll be supporting participants via a shared Google Doc—reviewing their plans, leaving comments, suggesting resources.

## My current bottleneck

**Ideation.** The hard part is helping non-technical people identify projects that are:
- Actually useful to them (not toy demos)
- Feasible in ~1 hour with Claude Code
- Within Claude Code's current capabilities (code + file manipulation + APIs + browser automation)

## What makes a good workshop project

- Automates something they currently do manually and repeatedly
- Mostly code—Claude Code can write it, test it, and get it running
- Minimal external setup (ideally zero new accounts; one API key at most. though this can be flexible depending on founder comfort with the setup)
- Produces a tangible artifact: a working script, a local web app, a spreadsheet pipeline, a bot
- Uses tools/services they already have (Google Workspace, Slack, email, spreadsheets)

## What makes a bad workshop project

- Requires creating multiple accounts or complex infrastructure (AWS, databases, DNS)
- Depends on proprietary systems Claude Code can't access
- Is really a "configure an existing SaaS" task, not a "build something" task
- Would take a senior engineer more than 2 hours

## Planning phase

Before a participant starts building, there should be a clear plan. The plan must:
- List concrete steps in implementation order
- Flag steps requiring human action (e.g., "enable the Gmail API in Google Cloud Console")
- Estimate which steps Claude Code does vs. which the human does
- Warn about steps that might be slow or tricky for first-timers, with a note like: "This might take a few minutes if you haven't done it before. Ask for help and I can walk you through it."

## Available affordances to curate

I want to maintain a list of pre-tested tools, MCP servers, and skills that participants can use. These should be things I or someone I trust has verified work well. For each, note:
- What it does
- What setup it requires (API keys, accounts, permissions)
- How hard the setup is (trivial / moderate / painful)

### Some starting available skills
- Google Workspace skills: Gmail, Calendar, Sheets, Docs, Drive, Tasks, Chat, Keep, Slides
- Chrome browser automation (claude-in-chrome)
- Web fetching and searching (WebFetch, WebSearch)

## Test session learnings

### Session 1: [date] — [founder name/org type]
*(Capture: what they wanted to build, what actually happened, where they got stuck, how long it took, what I'd change)*

## Open questions

- What payment/finance tools do CE founders commonly use? (Ask during test session)
- What other standard tools beyond Google Workspace? (Slack? Notion? Airtable?)
- Should Chrome automation (claude-in-chrome) be pre-installed for everyone, or only offered as needed?
- How to handle the ideation step efficiently in a group setting—individual brainstorm then share, or guided examples first?
