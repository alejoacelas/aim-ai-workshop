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

Codex (from OpenAI) has the best desktop app. Claude Code is a more likable agent, but runs in the :def[terminal]{the text-based interface where you type commands—like texting your computer instead of clicking}, which takes some time to get used to. Pick one and follow the instructions.

Agents burn through :def[tokens]{the units AI measures text in—roughly ¾ of a word each} fast. If you already have an AI subscription, use it (or get one now—I think you won't regret it).

:::tabs{id="agent"}
:::tab[Claude Code]

:::tabs{id="os"}
:::tab[Mac]

**Step 1: Install helpme**

Open Terminal. (Press Cmd + Space, type "Terminal", hit Enter)

This gives you better error messages if anything goes wrong during setup. Paste this and hit Enter:

:::prompt
curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.sh | bash
:::

**Step 2: Install Homebrew**

:::prompt
helpme "bash -c \"$(curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-homebrew.sh)\""
:::

Type your login password when prompted—it won't show as you type, that's normal.

**Step 3: Install Claude Code**

:::prompt
helpme "curl -fsSL https://claude.ai/install.sh | bash"
:::

Wait a few minutes. When it finishes, type `claude` to launch it. Navigate the menu with arrow keys and Enter.

:::aside[Troubleshooting: "command not found"]
If typing `claude` gives an error right after installation, copy all the terminal output, paste it back into Claude Code (or Claude.ai), and ask it to fix the problem. Run whatever it suggests, then close and reopen your terminal.
:::

:::
:::tab[Windows]

**Step 1: Install helpme**

Open PowerShell (press the Windows key, type "PowerShell", hit Enter). This gives you better error messages if anything goes wrong during setup. Paste this and hit Enter:

:::prompt
irm https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/helpme/install.ps1 | iex
:::

**Step 2: Install Git**

Download from [git-scm.com](https://git-scm.com/install/windows). Click Next on every screen—the defaults are fine. Wait for it to finish before moving on.

**Step 3: Install Claude Code**

:::prompt
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
5. If you're on a free plan, click the model dropdown and select GPT-5.1—the more powerful models require a subscription

:::
:::endtabs

---

## Install a markdown editor

Agents love :def[markdown]{a simple way to format text using symbols like # for headings and ** for bold}—it's how they format documents, create tables, and structure their work. Having a dedicated app to view these files makes everything easier.

:::tabs{id="editor"}
:::tab[Visual Studio Code (recommended)]

VS Code is a popular code editor that also previews markdown beautifully.

:::tabs{id="os"}
:::tab[Mac]

1. Go to [code.visualstudio.com](https://code.visualstudio.com/)
2. Click the big blue **Download for Mac** button
3. Open the downloaded `.zip` file—it extracts to `Visual Studio Code.app`
4. Drag `Visual Studio Code.app` into your Applications folder
5. Open it from Applications (if you get a security prompt, click **Open**)

:::
:::tab[Windows]

1. Go to [code.visualstudio.com](https://code.visualstudio.com/)
2. Click the big blue **Download for Windows** button
3. Open the downloaded `.exe` installer
4. Click Next through the setup wizard—defaults are fine
5. Click Install, then Finish

:::
:::endtabs

:::
:::tab[Obsidian]

[Obsidian](https://obsidian.md/) is popular for note-taking and handles markdown well. Download it from obsidian.md and follow the installer.

:::
:::endtabs
