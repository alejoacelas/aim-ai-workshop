---
title: "T0: Install your AI agent"
id: "install"
time: "15 min"
order: 1
---

# Install your AI agent

:::context[What agents can do that regular AI can't]

- **Control your computer** — every browser, app, or automation you already have. And they can install more on the internet.
- **Work in parallel** — split big problems into pieces and run them simultaneously. Have 20 documents to review? Do them all at once.
- **Build their own memory** — create and reference notes, personalities, rules, and patterns across sessions

:::

## Choose your agent

Claude has both a desktop app and a :def[terminal]{an app that gives direct commands to your computer using text-only instructions}-based agent called Claude Code. The terminal version is what we'll use here—its main advantage is that you can open many tabs and run tasks in parallel, which is how power users get the most out of it. Codex (from OpenAI) is the main alternative.

Agents burn through :def[tokens]{fancy AI term for a 'word'. Because AIs are multilingual and need to compress text, they don't quite correspond to words (e.g., they may chop and join words in a sentence differently), but it's close enough for most practical purposes} fast. If you already have an AI subscription, use it (or get one now—I think you won't regret it).

:::tabs{id="agent"}
:::tab[Claude Code]

:::tabs{id="os"}
:::tab[Mac]

**Step 1: Open terminal**

Press Cmd + Space, type "Terminal", hit Enter.

Alternatively, click on the Applications icon on the dock, type "Terminal" and select it.

Try typing `ls` and hit Enter to see a list of files and folders. 

**Step 2: Install helpme command**

Paste the following on your terminal and hit Enter:

:::terminal
curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.sh | bash
:::

We created this tool (with Claude Code!) to guide you on using the terminal. If you pass it any command, it will run it on the terminal and then explain what it did. Try `helpme "ls"` to see how it works.

Make sure to always pass the command in double-quotes (""), otherwise it may not work as you expect.

**Step 3: Install Homebrew**

Paste on your terminal:

:::terminal
helpme "bash -c \"$(curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-homebrew.sh)\""
:::

Type your login password when prompted—it won't show as you type, that's normal.

**Step 4: Install Claude Code**

:::terminal
helpme "curl -fsSL https://claude.ai/install.sh | bash"
:::

Wait a few minutes. When it finishes, type `claude` to launch it. Navigate the menu with arrow keys and Enter.

:::
:::tab[Windows]

**Step 1: Open PowerShell**

Press the Windows key, type "PowerShell", hit Enter.

Try typing `ls` and hit Enter to see a list of files and folders.

**Step 2: Install helpme command**

Paste the following on your terminal and hit Enter:

:::terminal
irm https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.ps1 | iex
:::

We created this tool (with Claude Code!) to guide you on using the terminal. If you pass it any command, it will run it on the terminal and then explain what it did. Try `helpme "ls"` to see how it works.

Make sure to always pass the command in double-quotes (""), otherwise it may not work as you expect.

**Step 3: Install Git**

Download from [git-scm.com](https://git-scm.com/install/windows). Click Next on every screen—the defaults are fine. Wait for it to finish before moving on.

**Step 4: Install Claude Code**

:::terminal
helpme "irm https://claude.ai/install.ps1 | iex"
:::

Wait a few minutes. When it finishes, type `claude` to launch it. Navigate the menu with arrow keys and Enter.

:::aside[Troubleshooting: "command not found"]
If typing `claude` gives an error right after installation, copy all the terminal output, paste it back into Claude Code (or Claude.ai), and ask it to fix the problem. Run whatever it suggests, then close and reopen PowerShell.
:::

:::
:::endtabs

:::
:::tab[Codex (ChatGPT)]

1. Download the app from [openai.com/codex](https://openai.com/codex/)
2. Sign in with your OpenAI account
3. Open a folder where your agent will save files
4. Click **Set up agent sandbox** above the chat input bar
5. If you're on a free plan, click the model dropdown and select GPT-5.2—the more powerful models require a subscription

:::
:::endtabs

---

:::aside[Optional: install a markdown editor]
Agents love :def[markdown]{a simple way to format text using symbols like # for headings and ** for bold}—it's how they format documents, create tables, and structure their work. Having a dedicated app to view these files makes everything easier.

**Visual Studio Code** (recommended): download from [code.visualstudio.com](https://code.visualstudio.com/), install, and you're set. It previews markdown beautifully.

**Obsidian**: popular for note-taking. Download from [obsidian.md](https://obsidian.md/).
:::
