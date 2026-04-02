# TODO: Workshop Site Expansion

## 1. Personalized onboarding flow

The landing page should prompt you to choose from a small set of options before showing content:

- **Operating system** — Mac, Windows, Linux
- **Existing subscription** — "Do you have a Claude or ChatGPT subscription?" If no, link them to a page explaining why they should consider getting one.
- **Time available** — Based on this, recommend a subset of content. Use hard-coded rules: if you have X time, do these steps.
- **Depth preference** — "I just want to get it installed and running ASAP" vs. "I want more context and explanation." This controls how much surrounding content is shown.

## 2. Aggressive step-by-step UI

The current page reads like a standard document. It should force you to pay attention to what matters:

- Numbered steps should be visually dominant — big step numbers, 3-5 words in large text describing the action, then a smaller explanation below.
- The design should be much more aggressive about guiding users through each action in the order the writer expects. Less "article," more "guided walkthrough."

## 3. Adversarial user testing via agent

Build an internal agent (an `.md` configuration or skill) that role-plays as a user going through the tutorial. It should systematically identify what's most likely to go wrong — e.g., user forgets to reload the terminal and doesn't see the command. Be thorough: cover every step and every common failure mode.

## 4. Detailed per-user analytics

Track individual user journeys through the page:

- Time spent on each page/section
- Timestamps of navigation events (clicked to next page, clicked a link)
- Which links were clicked
- Full journey reconstruction per user

This data should feed into a report on how the tutorial is performing.

## 5. Terminal-to-web integration via `helpme` CLI

The `helpme` CLI could be enhanced so the web page and terminal are connected:

- Dynamically generate a custom install command per user (ties their terminal session to their web session).
- The CLI pings the same servers as the web page, so terminal events are recorded alongside web events.
- Possibly surface a chat interface on the web page that uses information from the terminal.
- All of this is recorded with the rest of the tracking data.

**Open question:** Some people will use Codex or other tools instead of Claude Code. For now, assume Claude Code only, but this needs more thought.

## 6. Better content authoring format

Currently articles are written in Markdown and parsed for the web page, but this is essentially reinventing CSS/Tailwind. The goal:

- Individual pages should be separate files in a format that is **readable as plain text** and **easy to edit by hand**.
- Use something like semantic classes and a small set of custom directives, so files stay clean but the rendered page has rich formatting.
- The format should be easy enough that a non-technical person could edit a page without needing to understand the rendering system.

---

## Implementation notes (tentative — investigate before committing to any of these)

- **Onboarding flow:** Could be client-side state with query params or localStorage, no backend needed. But you should investigate whether something like a lightweight quiz framework or even just conditional rendering in the existing Astro/React setup would be simpler than building from scratch.
- **Step UI:** Look into whether an existing "stepper" or "wizard" component pattern fits before designing a custom one. There may be Tailwind-based step components that get you 80% of the way.
- **Adversarial testing agent:** A Claude Code skill (`.md` file) that prompts Claude to walk through the tutorial step by step and list failure points could work. But investigate whether a Playwright-based automated walkthrough would catch more real issues.
- **Analytics:** Something like Posthog, Plausible, or even a lightweight custom event logger with Cloudflare Workers could work. Investigate what gives you per-user journey data without heavy infrastructure. Avoid Google Analytics — it won't give you the granularity described here without significant configuration.
- **Terminal-web bridge:** This is the most architecturally complex piece. Investigate whether the existing `helpme` worker on Cloudflare could be extended with WebSocket or SSE to relay events, or whether a simpler polling approach is sufficient.
- **Content format:** Look into MDX, Markdoc, or even a custom lightweight markup with a small parser. Markdoc (from Stripe) might be the sweet spot — it's Markdown-based but supports custom tags and attributes cleanly. Investigate before picking one.
