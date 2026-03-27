---
title: "T1: Clean up your Downloads folder"
id: "clean-downloads"
time: "10 min"
order: 2
---

# Clean up your Downloads folder

Here you'll get a bit more used to having an AI take actions on your computer, and letting it act without your direct supervision.

---

## Step 1: Run your first agentic task

Open your agent and paste in this prompt:

:::prompt
Delete any unnecessary files in Downloads to save space
:::

Notice how it **asks your permission** before doing any permanent change to your computer. This is the default behaviour—just hit Enter to approve each step. It's a bit slow, but it means you always know what's happening.

---

## Step 2: Try a more specific prompt

Now try a better-specified version of the same task:

:::prompt
Suggest files in my Downloads folder I could delete to save space. If a file's name isn't descriptive, read it and give me a one-line summary of what it is.
:::

Review the suggestions, then follow up with "Do it" or name specific files to delete.

:::aside[Speeding things up: unrestricted permissions]
Once you're comfortable with how your agent works, you can skip the permission prompts entirely:

**Claude Code:** close the current session (`/exit` or Ctrl + C twice), then relaunch with:

:::terminal
claude --dangerously-skip-permissions
:::

**Codex (ChatGPT):** in the permissions dropdown below the chat input box, select **Full Access**.

This is what most power users do—including us. AI labs invest heavily to make sure agents do what you ask, and you can always toggle permissions back. If you're curious about the trade-offs, see [this guide to permission whitelisting](https://wow.pjh.is/journal/claude-code-permissions-whitelist).
:::
