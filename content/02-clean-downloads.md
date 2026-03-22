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

Notice how it **asks your permission** before doing any permanent change to your computer. This is the default behavior.

---

## Step 2: Give your agent unrestricted permissions

Checking in every time is useful for genuinely risky tasks, but it gets in the way for most work. For this session, we recommend giving your agent full permissions so it can move fast.

:::tabs{id="agent"}
:::tab[Claude Code]

Close the current session (`/exit` or Ctrl + C twice). Open a new session and run:

:::terminal
claude --dangerously-skip-permissions
:::

Once Claude is running, you can toggle unrestricted permissions off at any time with Shift + Tab (or Option/Meta + M), but you probably shouldn't.

:::
:::tab[Codex (ChatGPT)]

In the permissions dropdown below the chat input box, select **Full Access** instead of Default Permissions.

:::
:::endtabs

:::aside[Why give an AI agent unrestricted control of my computer?]
It's mostly safe, and it's what most power users do—including us.

What was the last time you deleted all your files while creating a PowerPoint? AI labs invest heavily to make sure agents do what you ask.

While there are [alternatives](https://wow.pjh.is/journal/claude-code-permissions-whitelist), giving agents full permissions is an extremely convenient starting point. If you're curious about the risks, ask your group lead.
:::

---

## Step 3: Try a more specific prompt

Now that your agent can act freely, give it a better-specified version of the same task:

:::prompt
Suggest files in my Downloads folder I could delete to save space. If a file's name isn't descriptive, read it and give me a one-line summary of what it is.
:::

Review the suggestions, then follow up with "Do it" or name specific files to delete. No need to supervise your agent now that you found a better way to delegate it work.
