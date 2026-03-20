---
title: "Connect Google Workspace"
id: "google-workspace"
time: "20 min"
order: 4
---

# Connect Google Workspace

Once connected, your agent can read your Gmail, create calendar events, edit Sheets, manage Drive files, all without you having to click around to find it.

## Create a project

1. Go to [console.cloud.google.com](https://console.cloud.google.com/)
2. Click the project dropdown (top left) → **New Project**
3. Name it something like "Agent CLI Tools" → **Create**
4. Select the new project from the dropdown

## Enable APIs

Go to **:def[APIs]{ways for software to talk to other software—here, it lets your agent access Google services} & Services → Library** and enable each of these:

- Gmail API
- Google Calendar API
- Google Drive API
- Google Docs API
- Google Sheets API

Search for each by name, click into it, click **Enable**.

## Configure the :def[OAuth]{a standard way to let apps access your account without giving them your password} consent screen

Go to **APIs & Services → OAuth consent screen**.

1. Select **External** user type → **Create**
2. Fill in the required fields:
   - App name: anything (e.g. "CLI Tools")
   - User support email: your email
   - Developer contact email: your email
3. Click **Save and Continue** through the remaining steps (Scopes, Test Users, Summary)—defaults are fine for now

## Create OAuth credentials

Go to **APIs & Services → Credentials**.

1. Click **Create Credentials → OAuth client ID**
2. Application type: **Desktop app**
3. Name: anything (e.g. "CLI")
4. Click **Create**
5. Download the JSON file—you'll need it in a moment

## Publish the app

Go to **APIs & Services → OAuth consent screen** and click **Publish App**.

:::context[Why publish?]
If you leave the app in "testing" mode, you'll be logged out every 7 days. Publishing keeps you logged in. Your app will be limited to 100 users unless you verify it (a process that takes 4–6 weeks and isn't worth it for personal use).
:::

## Authorize your accounts

Ask your agent to install the Google Workspace CLI and authorize it:

:::prompt
Install the Google Workspace CLI from https://github.com/googleworkspace/cli and authorize it using the JSON credentials file I downloaded. Walk me through each step.
:::

Follow the prompts. When you're done and your agent confirms everything is working, delete the JSON credentials file—you no longer need it.

## Test it

Try asking your agent something that requires Google access:

:::prompt
What are my 5 most recent emails? Summarize each in one sentence.
:::

:::prompt
What's on my calendar for the next 3 days?
:::

If it works, you're connected. If not, ask your agent to help troubleshoot.
