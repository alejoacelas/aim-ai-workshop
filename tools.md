# Tools for making AI assistants more useful

Curated from every post on [wow.pjh.is/journal](https://wow.pjh.is/journal) by Peter Hartree. Sorted with the biggest time-savers and automation enablers at the top.


The tools many orgs might use are:

Slack (free nonprofit plan) — comms
Google Workspace (free nonprofit tier) — docs, email, calendar
Asana (50% nonprofit discount) — project management
Notion (discounted) — knowledge base / wiki
QuickBooks Online or Xero — accounting
Expensify — expense tracking
Deel or Gusto — contractor/employee payments (Deel for international, Gusto for US-only)
Greenhouse or Airtable — hiring (if running structured rounds)
Zoom (50% off via TechSoup) — meetings
Every.org — donation page
Jitasa or Impact Ops — outsourced bookkeeping


---

### Google Workspace MCP (hardened fork)
Give Claude Code read/write access to Gmail, Google Drive, Google Calendar, Google Docs, and Sheets (20+ tools). Create calendar events, send emails, pull documents—all from the terminal.
- **Link:** https://github.com/c0webster/hardened-google-workspace-mcp
- **Original:** https://github.com/taylorwilsdon/google_workspace_mcp
- **Post:** [Give Claude Code access to your Gmail, Google Drive and Google Calendar](https://wow.pjh.is/journal/claude-code-google-workspace-mcp)


### Playwright
Browser automation framework for scripting deterministic web tasks. Claude Code can write and run Playwright scripts to automate repetitive browser workflows.
- **Link:** https://playwright.dev
- **Post:** [Claude Code does my bookkeeping](https://wow.pjh.is/journal/claude-code-does-my-bookkeeping)

### Claude in Chrome / Claude for Chrome
Browser extension that integrates Claude into Chrome for browser automation. In Claude Code, enabled via `claude --chrome` for testing loops and non-coding tasks.
- **Docs:** https://code.claude.com/docs/en/chrome
- **Post:** [Claude Code: enable Chrome browser use by default](https://wow.pjh.is/journal/claude-code-chrome-browser-use)


### Claude skill: Send invoices
Automates the full invoicing workflow—pulls hours from Toggl, creates invoices in Xero, emails them via Gmail, and verifies payment. Orchestrates multiple services in one skill.
- **Link:** https://wow.pjh.is/journal/claude-skill-send-my-invoices
- **Services used:** [Xero](https://xero.com), [Toggl](https://toggl.com), Gmail, Google Calendar, Obsidian

### Claude skill: Slack integration
Read and post Slack messages, automate weekly digests, and pipe data from other sources into Slack channels.
- **Link:** https://github.com/HartreeWorks/claude-skill--slack
- **Post:** [Claude Skill: Read and post Slack messages](https://wow.pjh.is/journal/claude-skill-slack)

### Claude skill: OKR progress report (meta-skill)
A template that helps staff create personalized OKR progress report generators by connecting Claude with Google Drive, Gmail, Google Calendar, and other data sources.
- **Link:** https://github.com/HartreeWorks/claude-skill--create-okr-digest-metaskill/blob/main/SKILL.md
- **Post:** [Claude Skill: Make an OKR progress report](https://wow.pjh.is/journal/okr-progress-report-claude-skill)

### Claude skill: Bookkeeping
Uses the Xero API to reconcile bank transactions, manage balance sheets, and handle accounting tasks programmatically—no web UI clicking.
- **Post:** [Claude Code does my bookkeeping](https://wow.pjh.is/journal/claude-code-does-my-bookkeeping)

### Granola + summarization skill
Call recording/summarization tool. Saves transcripts that Claude can process with custom prompts for better meeting summaries. Can auto-share to Notion.
- **Link:** https://granola.ai
- **Skill:** https://github.com/HartreeWorks/skill--summarise-granola/blob/main/SKILL.md
- **Post:** [Let Claude access your call transcripts](https://wow.pjh.is/journal/give-claude-call-transcripts), [My meeting summarization prompts](https://wow.pjh.is/journal/meeting-summarization-prompts)

### Zapier (as Claude connector)
Lets Claude.ai access hundreds of external services through Zapier's automation platform. Also works as a workaround to let Claude.ai read any public URL (via URL to Text).
- **Link:** https://zapier.com
- **Connector:** https://www.claude.com/connectors/zapier
- **Post:** [How to let Claude.ai read any URL](https://wow.pjh.is/journal/claude-ai-access-any-url), [How to make workflow automations that don't break](https://wow.pjh.is/journal/robust-workflow-automation)
- 
### Claude skill: Publish blog post
Automates the blog post publishing workflow—checks a draft, then publishes it.
- **Post:** [Claude Skill: check a draft blog post, then publish it](https://wow.pjh.is/journal/publish-blog-post-claude-skill)

---

## Tier 2: Developer workflow and productivity

Tools that make working with coding agents faster and smoother day-to-day.

### Shared skills directory (`~/.agents/skills/`)
Share skill files across Claude Code, Codex, and Gemini CLI. Place skills in `~/.agents/skills/` and symlink into each agent's directory.
- **Post:** [How to share skills between Claude Code, Codex and Gemini](https://wow.pjh.is/journal/share-skills-between-coding-agents)
- **See also:** skills.sh (referenced in roundups) for cross-agent skill management


### Claude skill: Computer use (URSSAF example)
Uses Claude Code's built-in browser to automate government portal interactions—login, navigation, document downloads.
- **Post:** [Claude Skill: use a web browser to review tax messages on a government portal](https://wow.pjh.is/journal/claude-skill-computer-use-urssaf)

### Claude skill: Make image
Routes image generation through Krea when official APIs are region-blocked.
- **Krea:** https://www.krea.ai
- **Post:** [Claude Skill: Make image](https://wow.pjh.is/journal/claude-skill-make-image)

### Claude skill: Create spaced repetition cards
Automates flashcard creation in Mochi from notes via Claude Code.
- **Mochi:** https://mochi.cards
- **Post:** [Claude Skill: Create spaced repetition cards](https://wow.pjh.is/journal/claude-skill-create-spaced-repetition-cards)

### Claude skill: LessWrong weekly digest
Uses the LessWrong API (no auth needed) to generate weekly digests of comments by specific users.
- **Post:** [Claude Skill: Weekly digest of LessWrong comments by Daniel Kokotajlo](https://wow.pjh.is/journal/follow-lesswrong-user-comments)

### Firecrawl
Web scraping/data extraction for gathering data to feed into LLM workflows.
- **Link:** https://firecrawl.dev

### Google Scholar PDF Reader
Chrome extension for enhanced academic paper research, useful for feeding research into LLM workflows.
- **Link:** https://chromewebstore.google.com/detail/google-scholar-pdf-reader/dahenjhkoodjbpjheillcadbppiidmhp

### Airtable Field Agents
Sends bulk prompts to LLMs and returns results in spreadsheet format. Useful for classification, extraction, and data enrichment.
- **Referenced:** https://wow.pjh.is/journal/airtable-field-agents

### Hammerspoon
macOS automation tool for binding custom keyboard shortcuts to Lua scripts. Used to create screen blackout shortcuts for focused multi-agent work.
- **Link:** https://www.hammerspoon.org
- **Post:** [Screen blackout shortcuts to support focus](https://wow.pjh.is/journal/screen-blackout-shortcuts)

### Raycast (Hyperkey)
macOS launcher whose Hyperkey feature remaps Caps Lock to Cmd+Ctrl+Alt+Shift, making it easy to create unique shortcuts for tools like Hammerspoon.
- **Link:** https://manual.raycast.com/hyperkey

---

## Reference guides the author published

- **Guide: Claude Code for non-technical staff** — https://coefficientgiving.notion.site/Public-Copy-Guide-to-Claude-Code-2d473193127d4cd68f890b230c4ae785
- **Guide: Claude Cowork and Claude for Chrome** — https://coefficientgiving.notion.site/Public-Copy-Guide-to-Claude-Cowork-and-Claude-for-Chrome-19f6e4bb37fe4597ac105317ee98ab04
