# Tab 1: Demo

---

## Install Claude Code / Codex

Start downloading now—we'll explain what these are while they install.

We suggest you try both [Claude Code](https://www.anthropic.com/claude-code) (most popular) and [Codex](https://openai.com/codex/) (by OpenAI, great desktop app).

### Claude Code

Don't use the Claude Code desktop app—use the terminal version.

1. Open your terminal app:
   - **Mac:** press Cmd+Space, type "Terminal", and hit Return
   - **Windows:** press Windows key + R, type "wt", and press Enter
2. Install:
   - **Mac:** `curl -fsSL https://claude.ai/install.sh | bash`
   - **Windows:** `irm https://claude.ai/install.ps1 | iex`
3. Launch it: `claude`

If you run into trouble, ask your favorite chatbot for help. You can also install [Warp](https://www.warp.dev/), a terminal with a built-in chatbot that can solve install issues for you.

### Codex

Download the app from [openai.com/codex](https://openai.com/codex/)—available on the Mac App Store and Microsoft Store. Sign in with your OpenAI account (a $20/month ChatGPT Plus subscription works). Open a project folder and start prompting.

To see the plans, memories, and files from your agents, get a markdown editor you like. Try [Obsidian](https://obsidian.md/) (popular), [Typora](https://typora.io/) (simplest), or [VS Code](https://code.visualstudio.com/) (common among coders).

Your Claude / ChatGPT subscription should give you enough tokens for this session, though you should seriously consider the $100/$200 plans. [TODO: blog post making the case for this — see [Everyone should use Claude Code](https://wow.pjh.is/journal/everyone-should-use-claude-code)]

## What are coding agents?

AI, but on your computer, running code. Advantages:

* Create and reuse memories and intermediate outputs
* Extend and customize it, using code created by anyone
* Split tasks across agents; invest extra effort in the important parts

## Security note

Two risks worth knowing about:

1. **Prompt injection** — malicious instructions hidden in content the agent reads (a webpage, a document, an email). The agent might follow those instructions instead of yours.
2. **Agent errors** — the agent does something wrong. Deletes the wrong file, sends an email you didn't want, misunderstands a task.

These are mostly not practical problems—agents are reliable enough for everyday tasks, and they ask before doing anything dangerous. For this session, it's fine to give full permissions so things go smoothly. [TODO: Link to Peter's allowlist approach for a more conservative setup.]

## Glossary

* **Skills:** text files with instructions to perform a task. Can include code scripts to perform things on your computer. If the agent struggles and you plan to do something similar again, tell it: "create a skill with what you learned to do this task better next time." You can also use skills made by other people—install them and the agent can follow their instructions just like your own.
  * [Invoice skill](https://wow.pjh.is/journal/claude-skill-send-my-invoices) — automates the full invoicing workflow: pulls hours from Toggl, creates invoices in Xero, emails them via Gmail.
  * [OKR progress report skill](https://wow.pjh.is/journal/okr-progress-report-claude-skill) — connects to Google Drive, Gmail, and Calendar to generate a progress report against your OKRs.
  * [Bookkeeping skill](https://wow.pjh.is/journal/claude-code-does-my-bookkeeping) — reconciles bank transactions and manages accounting tasks through the Xero API.
  * [Slack skill](https://wow.pjh.is/journal/claude-skill-slack) — reads and posts Slack messages, automates weekly digests, and pipes data from other sources into Slack channels.
* **[MCP](https://modelcontextprotocol.io/):** a standard for how AI agents talk to other apps. Ask your agent to install one, and it can connect to that service. Examples:
  * [Google Drive](https://github.com/modelcontextprotocol/servers/tree/main/src/gdrive)
  * [Asana](https://developers.asana.com/docs/using-asanas-mcp-server)
  * [Claude Chrome extension](https://code.claude.com/docs/en/chrome) ([setup guide](https://wow.pjh.is/journal/claude-code-chrome-browser-use)): AIs are bad at reasoning about what's on screen (e.g., they practically can't play old Pokémon games). This tool feeds them the text content of any webpage, so they can navigate it reliably.
* **Planning mode:** a setting (try Shift+Tab) that makes the agent flesh out a plan before acting. Great for complex tasks or when you don't know how to approach a problem.
* **Permission settings:** which actions your agent can take without asking you first. They're reliable enough that you can often give full permissions, but start with less to get a feel for what they do.
* **Claude.md / Agents.md:** text files automatically fed to your agent. Can be assigned to all agent sessions, or placed inside a project folder to be included just for that project. ([example](https://wow.pjh.is/journal/my-claude-md))

## Q&A time!

Ask any questions before we move on.

## How to get value out of them

* **Don't think about rate limits.** There's many things you won't attempt unless they feel basically free. I started using Claude Code ~5x more after the $200 plan—I never hit the rate limits.
* **Give them enough permissions.** You care about getting the task done. Permissions settings are there to prevent catastrophic mistakes, but for most tasks the agents are reliable enough you won't have to worry about this.
* **Give them context.** They're amnesiac. Prepare a Claude.md or Agents.md to passively feed context about what you do. Ask the AI to read your Drive, email, and everything else, then give you a first draft.
* **Collect learnings** about what they can easily do. These convert tasks from 'might do eventually' to 'can fire off a prompt now and collect the result in 10 min.'

Two ways people get lots of value:

* **Create a better assistant for your main line of work.** What do you spend more than 20% of your time on? Knowledge work, calls, strategy? Create files that give your AI better context and add skills/MCPs so it has access to what it needs to work.
* **Expand the range of tasks you can do right now.** If a task takes practically no effort, you do it on the spot—instead of scheduling it, delegating it, or not doing it at all.
  * A non-coder friend delayed updating their org's website for ~1 year, partly trying to find someone who could take on the task. After 20 minutes of setup, they set things up so they can edit their website by typing their changes to Claude Code.
  * [Classifying credit card entries](https://wow.pjh.is/journal/claude-code-does-my-bookkeeping) for reimbursement. If you do it well once with coding assistants, you don't have to do it again.
  * **Pro tip:** While one agent works, open another window (Cmd+N / Ctrl+N) and start something else. Use your full span of attention.

## Task ideas: build a better assistant

Think about this question: **"If you came out of this workshop thinking 'AI agents are the best thing ever,' what is it that you built?"**

* Does your LLM know how to read your Drive? [Set that up](https://wow.pjh.is/journal/claude-code-google-workspace-mcp), then have it draft an email, create a doc, or research a question.
  * Think of every platform that holds your thoughts and writing—docs, task manager, [call transcripts](https://wow.pjh.is/journal/give-claude-call-transcripts). Ask the AI how to give it access.
* Create a skill for something you do often. For me: a writing companion that polishes drafts for clarity.
  * Rule of thumb: if you're doing something twice and the AI doesn't nail it the first time, create a skill for it.

## Task ideas: try new affordances

Things that used to require a developer or hours of manual work:

* Create a website and publish it online using [Vercel](https://vercel.com/).
* Process any big dataset—clean it, analyze it, visualize the results.
* Build a simple internal tool (e.g., an automation to scan for grants and email you about grant deadlines).

## During the session

We'll use this tab [TODO: link to tab] where everyone writes their ideas and gets feedback.

1. **Write down your project idea** under your name in the shared doc. Include what you want to build, why it's useful, and any tools or services involved.
2. **We'll review your plan**—we'll leave comments directly in the doc: suggest tools, flag tricky steps, point you to relevant skills or connectors.
3. **Pick one idea and start building.** You don't need to wait for our comments.
4. **If you get stuck,** drop your question in the session chat or add it to your section in the doc. We'll circulate and help.

## Homework

Keep the momentum going:

* Try one more project this week. Something small, something real.
* [Install an MCP](https://wow.pjh.is/journal/claude-code-google-workspace-mcp) for a service you use daily (Drive, Slack, Calendar). Explore what it can do.
* [Create a Claude.md](https://wow.pjh.is/journal/my-claude-md) with context about your org and your role. Better context makes every future session more useful.
* Share what you built with your co-founders or team. If it's useful to you, it's probably useful to them.
* Read the [Guide to Claude Code for non-technical staff](https://wow.pjh.is/journal/coefficient-guide-to-claude-code) and the [Guide to Claude Cowork and Chrome](https://wow.pjh.is/journal/coefficient-guide-to-cowork).

---

# Tab 2: Tasks

Work through these tasks in order. If a task is running and you're waiting, move on to the next one (or watch the agent work if you feel you learn from that).

---

## Task 1: Clean up your Downloads folder

Ask your agent:

> "Which files could I delete in Downloads to save space?"

Review the suggestions. Then follow up:

> "Do it" (or pick specific ones to delete).

This shows the agent working with your local files—useful for computer management tasks.

## Task 2: Make a personal webpage

Ask your agent to create a personal webpage for you, deployed using the official Vercel skill.

**Claude Code users:** The agent can fetch your LinkedIn profile directly. Give it your LinkedIn URL.

**Codex users:** Codex can't fetch web pages. Go to LinkedIn → More → Save to PDF, then tell Codex to use that PDF as the source.

If the agents asks you to create a Vercel account, tell it that it's not necessary for this deployment.

## Task 3: Slash commands, planning mode, and full permissions

Try a few `/` commands to see what's available:

* **Claude Code:** Type `/` and browse the list. Try `/plan` to enter planning mode—the agent will think through a plan before acting. Press Shift+Tab to toggle planning mode on and off.
* **Codex:** Type `/` to see available commands.

Now give your agent full permissions so it can work without asking you to approve every step. This is the biggest quality-of-life improvement—it turns the agent from something you babysit into something you delegate to.

* **Claude Code:** Run `claude --dangerously-skip-permissions` (or restart with that flag). This lets the agent run commands, edit files, and access the network without asking first.
* **Codex:** Go to Settings → set "Full Auto" mode. This gives the agent full access to run commands and make changes.

From this point on, use full permissions for the rest of the workshop.

## Task 4: Install skills and read them

Install the workshop skills. Ask your agent:

> "Install the skills from https://github.com/alejoacelas/aim-ai-workshop"

Or run directly: `npx skills add alejoacelas/aim-ai-workshop`

Then ask:

> "Open one of the skills to read it in a text editor."

Each skill lives in its own directory under `skills/` with a `SKILL.md` file—that's the standard format for sharing skills. This lets you see what skills look like and learn how to use skills made by other people.

## Task 5: Ideation and project planning

Think of 3 project ideas. Use this prompt to help:

> "If you came out of this workshop thinking 'AI agents are the best thing ever,' what is it that you built?"

For each idea, run `/plan-project` to red-team feasibility. The skill will check dependencies, test integrations, estimate timing, and flag problems.

Pick the most promising one and start building.
