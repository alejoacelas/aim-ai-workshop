---
title: "T1: Clean up your Downloads folder"
id: "clean-downloads"
time: "10 min"
order: 2
---

# Clean up your Downloads folder

This task is for you to get used to an AI taking actions on your computer, and doing so without your direct supervision.

---

## Step 1: Run your first agentic task

Open your agent and paste in this prompt:

:::prompt
Delete any unnecessary files in Downloads to save space
:::

Notice how it **asks your permission** before doing anything irreversible. This is the default behavior.

---

## Step 2: Give your agent unrestricted permissions

Checking in every time is useful for genuinely risky tasks, but it gets in the way for most work. For this session, we recommend giving your agent full permissions so it can move fast.

:::tabs{id="agent"}
:::tab[Claude Code]

Close the current session (`/exit` or Ctrl + C twice). Open a new session and run:

:::prompt
claude --dangerously-skip-permissions
:::

Once Claude is running, you can toggle unrestricted permissions off at any time with Shift + Tab (or Option/Meta + M).

:::
:::tab[Codex (ChatGPT)]

In the permissions dropdown below the chat input box, select **Full Access** instead of Default Permissions.

:::
:::endtabs

:::aside[Why give an AI agent unrestricted control of my computer?]
It's mostly safe, and it's what most power users do—including us.

What was the last time you deleted all your files while creating a PowerPoint? AI labs invest heavily to make sure agents do what you ask.

While there are alternatives, giving agents full permissions is an extremely convenient starting point. If you're curious about the risks, ask your group lead.
:::

---

## Step 3: Try a more specific prompt

Now that your agent can act freely, give it a better-specified version of the same task:

:::prompt
Suggest files in my Downloads folder I could delete to save space. If a file's name isn't descriptive, open it and give me a one-line summary of what it is.
:::

Review the suggestions, then follow up with "Do it" or name specific files to delete. Watch your agent work through the list without interrupting you at every step.
