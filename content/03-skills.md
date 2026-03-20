---
title: "Try using skills"
id: "skills"
time: "15 min"
order: 3
---

# Try using skills

:::context[Why skills are great!]
LLMs have no memory between sessions. Everything they "remember" is because they wrote it down somewhere they can see it again ([think Memento!](https://64.media.tumblr.com/1db32ff3b4f301b244e7e918cfb47a86/tumblr_p7wqr6aEqH1rob81ao2_400.gifv)). Because there are limits on how much text an agent can process at once, you can't just dump every past interaction back at them every time.

Skills are a simple and elegant solution. Each skill is a text file with a title, description, and instructions. The agent sees just the title and description at the start of every session, decides which ones are relevant, and reads the full content only when needed.

Think of skills as reusable expertise—you write/download them once (or have your agent write them), and they stick around for when you need them.
:::

### Step 1: Download the skills repo

Ask your agent to download the starter skills for this workshop:

:::prompt
Download the skills at https://github.com/alejoacelas/aim-ai-workshop. If git is not available, use brew install git (Mac) or ask me to install it (Windows).
:::

:def[GitHub]{a website where programmers share code and projects} is where we're downloading the skills from. You'll only need to do this once.

:::tabs{id="agent"}
:::tab[Claude Code]
Open a new terminal tab (Cmd + T on Mac, Ctrl + Shift + T on Windows) and start a new `claude` session to reload skills.
:::
:::tab[Codex (ChatGPT)]
Press Cmd + N to start a new session and reload skills.
:::
:::endtabs

Type `/skills` to confirm they installed correctly. You should see a list including `/setup-coding-env`, `/deploy-with-vercel`, and `/explain-project`. If they're not there, ask your coding agent what happened and have it fix it for you.

### Step 2: Try some skills

Type `/` followed by a skill name and hit Enter. Try each of these in a separate agent tab:

**`/setup-coding-env`** — Installs everything you need to run web apps and data analysis from your computer.

Then try:

:::prompt
Make me a tasteful personal website based on my LinkedIn profile. Tell me how to copy my profile info, then use /deploy-with-vercel to publish it online.
:::

:::prompt
/explain-project How did you create and host the website? How is the page design defined?
:::

While you wait, open another tab and start something else. **Running 3–10 agent tabs in parallel is how you really take advantage of this tool.**

If you ran `/setup-coding-env`, you can type `claude-yolo` in new tabs instead of the full `claude --dangerously-skip-permissions`.

:::context[What are skills like under the hood?]
Each skill is just a title (which you use to invoke it), a description (which the agent sees at the start of every session so it can decide if the skill is relevant), and a text file that's only loaded when the agent decides it needs it. That file can contain things like instructions for how to carry out a task, how to interact with a webpage, how to use a program, or a checklist for reviewing the quality of a piece of writing.

Try it—tell your agent to use `open` to show you the file for any of the skills you just installed. You'll see they're just text files.
:::

:::aside[What else can skills do?]
What can your computer do? Lots of things, I'd think. If you manage to do a task once with a coding agent, you can simply say: *"Make a skill for this, so I don't have to give you detailed instructions next time."*

Here are some skills people have built:

- [Invoice automation](https://wow.pjh.is/journal/claude-skill-send-my-invoices): Pull hours from Toggl, create invoices, email them to clients
- [OKR progress reports](https://wow.pjh.is/journal/okr-progress-report-claude-skill): Generate weekly reports from Drive, Gmail, and Calendar
- [Slack digest](https://wow.pjh.is/journal/claude-skill-slack): Read and post messages, generate weekly summaries
- [Meeting summaries](https://github.com/HartreeWorks/skill--summarise-granola/blob/main/SKILL.md): Extract transcripts from Granola and create custom summaries
:::

### Step 3: Try built-in Claude Code commands

Some slash commands come with Claude Code by default, not from skills:

- **`/plan`** — Makes the agent draft a plan and ask your input before doing anything. Use this for any non-trivial request.
- **`/voice`** — Dictate your prompt. Useful for complex projects or when you have a lot of context to give.
- **`/btw`** — Ask your agent a question without interrupting the current task.
