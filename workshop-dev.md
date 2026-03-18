---
gdoc: 1KBmzB07hHcoMALu6N4OHtE5Ua7-wdAd6l9LqCxUaE6g
title: [DEV] Claude Code AIM Founders
---
# Start Here

# Claude Code workshop for AIM founders

Goals:

* Reduce confusion around AI, get you up to speed with the latest  
* Get the basic knowledge so that you are ready to play further with AI and automation

In scope:

* 0 \-\> 1 guide for getting into vibe-coding, automations  
* Setting up Claude Code/Codex  
* How to handle security concerns  
* Ask any questions about AI trends

Out of scope:

* Setting up [OpenClaw](https://openclaw.ai/blog/introducing-openclaw) (famous Claude Code extension that you can chat with from Whatsapp/Slack/Telegram)

## Plan

Five tasks to complete:

1. Install Codex or Claude Code  
   1. (famous coding agents that let you do everything)  
2. Use your agent to clean up documents on your computer  
   1. (demonstrates how useful it is for computer management)  
2. Create skills for annoying things you do once a month e.g.  
   1. (demonstrates how to keep learning, access external services)  
2. Authorise Google Workspace connection  
   1. (how to link up your work stuff)  
2. Turn your spreadsheet into a sharable dashboard  
   1. (demonstrates how to quickly set up and share websites)

We’ll be in breakout rooms on Zoom  
\-\> Joey will host a general chitchat, help latecowmers  
\-\> Alejo will set people up in Codex  
\-\> Aaron and Luca will set people up in Claude Code

Approximate schedule:  
\-\> Welcome, 15 mins. Temperature checks, icebreakers ^.^  
\-\> Breakout rooms. 1.5 hours  
\-\> Final 10 mins: Group close for anyone remaining, discuss takeaways, things to try more of

We have 2 hours scheduled but may not need all of it. Strongly encourage a 10 min break in the middle, although you may be so happy about the coding that you don’t need it\!

## Session

All links direct you to tabs in this document. Go through them in order during the session.

0\\.   \[Install Claude Code or Codex\]()

4. [Clean up your Downloads folder](?tab=t.iv2qu1i8yful)  
5. Try using skills  
6. Connect your Google Workspace  
7. Create a neat Dashboard

# T0 \- Install your AI agent

## Install Claude Code / Codex

There are three fantastic options to try. They are all beginner friendly. We will split you up, so that you each get a decent option, and can learn from each others’ experiences later.

The agents are:

1) Codex (by Open AI);  
2) Claude Code, using Visual Studio Code (popular coding app that lets you look at your files);  
3) Claude Code, using the terminal only (speedier to run but slightly more confusing to look at)

**Quick decisioning:**

1) If you already pay for a Claude subscription, we will put you in one of the Claude groups  
2) If you have a ChatGPT subscription, we will push you to the [Codex app](https://openai.com/codex/).  
3) Anyone else, we will encourage you to try Claude Code

**First: install helpme**

Before we start installing anything, grab a small helper called `helpme`. If any command goes wrong, it tells you what happened and gives you the exact fix—no need to Google error messages.

Mac/Linux — paste into Terminal: `curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-helpme.sh | bash`

Windows — paste into PowerShell: `irm https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-helpme.ps1 | iex`

If the install worked, open a new terminal window so `helpme` is on your PATH. You'll see it in front of every command below. It watches the command run, and if something goes wrong, it explains the problem and offers to fix it for you. If everything works, it just tells you what happened.

| Codex  Download the app from [openai.com/codex](https://openai.com/codex/) Sign in with your OpenAI account Open a folder where you'll save any files your agent creates (If asked to) Click on ‘Set up’ agent sandbox above the chat input bar (If you don't pay a subscription) Click GPT-5.2 on the model dropdown, as the better models are paywalled Markdown editor Markdown is agents’ favorite language. It allows them to format text, create tables, and draw equations using straightforward symbol conventions. To visualize markdown files, it's helpful to have an app like [Obsidian](https://obsidian.md/) (popular), [Marktest](https://github.com/marktext/marktext?tab=readme-ov-file#download-and-installation) (personal favorite), or [VS Code](https://code.visualstudio.com/) (common among coders).  If you get stuck, ask the agent to help you\! We'll also be around to help, but don't be afraid to interrupt the agent to ask for context or open a new tab to interrogate it on what it's doing. |
| :---- |

| Visual Studio Code  (popular coding app that lets you look at your files)  Mac Go to code.visualstudio.com Click the big blue Download for Mac button Open the downloaded `.zip` file — it will extract to a file called `Visual Studio Code.app` Drag `Visual Studio Code.app` into your Applications folder Open it from Applications (you may get a security prompt — click Open) Windows Go to code.visualstudio.com Click the big blue Download for Windows button Open the downloaded `.exe` installer Click Next through the setup wizard (defaults are fine) Click Install, then Finish |
| :---- |

| Claude Code in Terminal Mac Install Homebrew Open Terminal (an app that looks like this) ![][image1] Alternatively, here is the Terminal section in Visual Studio Code ![][image2] Copy+paste the following: `helpme -- /bin/bash -c “$(curl -fsSL https://raw.githubusercontent.com/alejoacelas/aim-ai-workshop/main/install-homebrew.sh)”` Type in your lock screen password when prompted Install Claude Code — paste into Terminal: `helpme -- bash -c “$(curl -fsSL https://claude.ai/install.sh)”` Wait a few minutes for installation to finish, then type `claude` in the terminal. Windows Install Git: download from [git-scm.com](https://git-scm.com/install/windows) Click “Next” on every menu — none of the options matter Wait until installation finishes before proceeding Open PowerShell: press the Windows key, type “PowerShell”, and hit Enter Install Claude Code — paste into PowerShell: `helpme -- powershell -c “irm https://claude.ai/install.ps1 | iex”` Wait a few minutes for installation to finish, then type `claude` in the terminal. Once you see Claude's menu appear, navigate using the arrow keys and Enter. | | :---- |

# T1 \- Clean downloads

## **Task 1: Clean Up Your Downloads Folder**

### **Step 1: Run your first agentic task**

Ask Claude/Codex to:

*Delete any unnecessary files in Downloads to save space*

Notice how it **asks your permission** before taking any action with lasting effects on your computer. This is the default behaviour.

---

### **Step 2: Give Claude unrestricted permissions**

Checking in every time is helpful for genuinely risky tasks, but gets tiresome for most projects. That's why we recommend granting your agent unrestricted permissions for this session.

* ***Claude Code:*** Close the current session (`/exit` or Ctrl \+ C twice). Open a new session, and paste into the terminal:  
    
  *`claude --dangerously-skip-permissions`*  
    
* After Claude boots up, you can disable unrestricted permissions with `Shift + Tab (`or Option/Meta \+ M)  
    
* ***Codex:*** Select ‘Full Access’ instead of ‘Default Permissions’ on the dropdown below the chat input box/

*Note:* You can always disable unrestricted access during a session, or, what's often more convenient, change your instructions to help Claude flag any risky action before it's taken. While there are [alternatives](https://claude.ai/chat/2b4e6592-cb06-4d28-b91b-c6de39f9a99b#), giving agents full permissions is an extremely convenient starting point, and it's what most of the AI agent power users we know do (including us\!).

If you're curious about the risks, ask your group lead.

---

### **Step 3: Try a better-specified prompt**

Now paste this:

*Suggest files in Downloads I could delete to save space. If a file's name isn't descriptive, inspect its contents and give me a one-line summary of what it is*

Review the suggestions, then follow up with **"Do it"** or pick specific files to delete. Watch Claude act autonomously. No more interruptions\!

---

### **Step 4: Explore slash commands**

Type `/` to browse available commands.

* **Claude Code:** **`/plan`** — Claude thinks through a plan before acting  
* **`Shift + Tab`** — toggles planning mode on and off  
* **Codex:** **`Type`** `/` to see available commands.

# T2 \- Try skills

## Task 2: Try using Skills

**Step 1: Download skills repo**

Skills are pre-packaged expertise, which take the form of text files with instructions for your agent. We've prepared some starting skills for this session. Have your agent download them by asking:

*Download the skills at [https://github.com/alejoacelas/aim-ai-workshop](https://github.com/alejoacelas/aim-ai-workshop).*

*If git is not available, use `helpme -- brew install git` (on Mac, otherwise instruct the user to install. Homebrew may not be on path yet)*

That last sentence you'll only have to run once. GitHub is the social network where programmers share code and projects, and that's where we are downloading the skills from.

**Step 2: Try out some skills\!**

Now try typing **`/`** followed by the name of the skill, then hit Return. You have access to:

* `/setup-coding-env` will install everything you need to get started with running webpages and data analysis from your own computer  
    
* `/deploy-with-vercel` publish any webpage online. Try it out\! Just ask your agent  
    
  Build a tasteful app that reflects the aesthetics of my favorite book: \[YOUR FAV\]. Use vercel skill to deploy  
    
* `/explain-project` can be run on a previous agent run to get a layman explanation of what it did

*Troubleshooting*:  
1)Start a new claude code session, after downloading these skills.  
2)Type /skills \- to ensure that your skills have installed correctly

While you wait for your agent to finish, open another tab and try something else\! **You want to keep open 3-10 agent tabs and run things in parallel to take full advantage of your attention span.**

If you ran `/setup-coding-env` already, you can open a new tab and type `claude-yolo` instead of the full `claude --dangerously-skip-permissions.`

Beyond trying the skills above, here's some things you can do in parallel:

* Search for skills for something you want to do, or explore any of the ones below:  
    
  * [Invoice](https://wow.pjh.is/journal/claude-skill-send-my-invoices): Pull working hours from Toggl, create invoices, and email them to clients.  
  * [OKR progress report](https://wow.pjh.is/journal/okr-progress-report-claude-skill): Generate weekly progress reports from Drive, Gmail, and Calendar  
  * [Slack](https://wow.pjh.is/journal/claude-skill-slack): Read and post Slack messages, generate weekly digests  
  * [Summarize call](https://github.com/HartreeWorks/skill--summarise-granola/blob/main/SKILL.md): Extract meeting transcripts from Granola and create custom summaries


* Ask it to open the file that defines one of the skills we downloaded  
    
* Create a simple skill with just one prompt (you'll have time after the session to try more sophisticated things)  
    
  Create a skill that receives a time, and converts it from my timezone to London, New York, and SF time. If I use a timezone suffix (e.g., GMT), convert from that to LON, NY, SF and my timezone  
    
* Create another website\!

**Step 3: Try built-in Claude Code Commands**

Some slash commands are not skills, but rather features that come with the AI agent. A few useful ones for Claude Code are:

* `/plan` your go-to for any non-trivial requests. Makes the agent draft a plan and ask your input before executing the task  
* `/voice` Dictate your prompt. Useful for complex projects or when you don't quite know what you want yet, and want to give your agent enough context to figure it together  
* `/btw` Ask your agent questions about what it's doing without interrupting the task  
* `/copy` Copy the last output from the AI agent

# T3 \- Connect Google Workspace

## Task 3: Connect with Google Workspace

AI agents work best when they have access to as much relevant context as you can give them.

Because they're mostly text-in text-out machines, they prefer accessing that context through text interfaces, such as command-line tools, skills, or MCPs (text-only apps made especially for agents).

This is the most setup-heavy task in the workshop. It takes about 15 minutes, and most of it is clicking through Google's configuration screens. Once it's done, your agent will be able to read your emails, create calendar events, edit spreadsheets, and all other Google services.

**Step 1: Install the Google Workspace CLI**

Ask your agent to install the Google Workspace CLI tool for you:

Install the official gws CLI at [https://github.com/googleworkspace/cli](https://github.com/googleworkspace/cli)

**Step 2: Create a Google Cloud project**

- Open [https://console.cloud.google.com/](https://console.cloud.google.com/) in your browser  
- Click the project dropdown at the top of the page (it might say "Select a project" or show an existing project name)  
- Click **New Project** and name it "Everything-project"  
- Click **Create** Wait a few seconds for it to finish, then make sure your new project is selected in the dropdown at the top

**Step 3: Set up the consent screen**

Google needs to know a few things about what will be accessing your account, even though it's just you.

- Go to [https://console.cloud.google.com/apis/credentials/consent](https://console.cloud.google.com/apis/credentials/consent)  
- Select **External** as the user type and click **Create**  
- Fill in the required fields. The only ones that matter are  
  - **App name**: anything you like (e.g. "My AI Agent")  
  - **User support email**: pick your email from the dropdown  
  - **Developer contact email**: your email again  
- Click **Save and Continue** through the remaining screens (Scopes, Test users, Summary)—you don't need to change anything else yet  
- Now go back to the consent screen and click **Test users → Add users** Enter your Google account email and click **Save**

That last step is important. If you skip it, you'll get a confusing "Access blocked" error later.

**Step 4: Create credentials**

- Go to [https://console.cloud.google.com/apis/credentials](https://console.cloud.google.com/apis/credentials)  
- Click **\+ Create Credentials** at the top, then select **OAuth client ID**  
- For Application type, choose **Desktop app**  
- Give it any name (or leave the default) and click **Create**  
- A popup will show your client ID and secret  
- Click **Download JSON** and pick a folder to save it (e.g., Downloads)

Move the OAuth client JSON file I just downloaded to \~/.config/gws/client\_secret.json

**Step 5: Log in**

Now tell your agent:

Look for the client secret JSON at \[YOUR CHOSEN FOLDER\] and place it where it goes. Run gws auth login and walk me through the process.

Your agent will run the login command, which opens a browser window asking you to authorize access. A few things you might see:

**"Google hasn't verified this app"** — This is expected. Click **Advanced**, then **Go to \[your app name\] (unsafe)**. It's safe—this is your own project, not a published app. **Scope checkboxes** — Select the ones you need, or just **Select all** to give your agent broad access. You can always revoke this later.

Once you approve, the browser will redirect to a "success" page and your agent is connected.

**Step 6: Install the Google Workspace skills**

So that your agent knows what it can do with gws, you want to give it some instructions that it can reference (otherwise it might not even remember it installed gws\!). Open a new terminal and have it install the accompanying skills:

Summarize which skills are available from [https://github.com/googleworkspace/cli](https://github.com/googleworkspace/cli) and let me choose which ones to install

Once installed, you'll have access to skills for Gmail, Drive, Calendar, Docs, Sheets, and more. Type / to see them.

**Step 7: Try it out**

Ask your agent to do something with your Google account:

Show me my 5 most recent emails, What's on my calendar this week? List the files in my Google Drive

If your agent gets an error like "API not enabled", don't worry—it'll give you a link to click that enables the specific API (Gmail, Calendar, etc.) for your project. Click the link, hit **Enable**, wait a few seconds, and try again.

This was the exact prompt I used to create my work hub, using `/plan` to iterate a bit before implementing it:

I want you to thoroughly explore my Drive folder for Cliver work:  
[https://drive.google.com/drive/u/0/folders/18ecZPJsyeu0roYnbuMZ8WZGcFbUFa7W2](https://drive.google.com/drive/u/0/folders/18ecZPJsyeu0roYnbuMZ8WZGcFbUFa7W2)

Dispatch subagents to investigate the main folders and a separate one for the weekly planning logs. I want to use this folder as a central hub for managing strategy, goals, and periodic commitments for the project. Probably what you want to do is just pull a summary of the current state of the project, the main strategic decisions we've taken, goals for the next quarter (haven't defined those yet, but maybe we've hinted at what those could be), and a reference to where difference pieces of information are located (that last one is more for you, so you can easily navigate my Drive and info repositories going forward)

Try something like it for yourself\!

# T4 \- Dashboard

## Task 4: Turn a spreadsheet into a dashboard

You've got data sitting in a Google Sheet. Right now, when someone asks you for a status update, you send them a link to the spreadsheet and hope they can make sense of it.

In this task, your agent will turn that spreadsheet into a clean, shareable dashboard—a real webpage that anyone can open in their browser.

**What you'll need:**

A Google Sheet with some data in it. It doesn't need to be fancy—a table with headers is enough. If you don't have one handy, ask your agent:

Create a sample Google Sheet with a simple grants pipeline: organization name, amount requested, status, and date submitted. Add 10 example rows.

That requires the Google Workspace connection from the previous task. If you skipped it, you can also just point your agent at a local CSV or paste a table directly into the chat.

Step 1: Build the dashboard

Tell your agent what you want. Be specific about what matters \- your agent will make design choices for you, but it helps to know what you care about. Here are some prompts to start from:

*Read \[SPREADSHEET URL\] and build a dashboard that shows the total funding requested, a breakdown by status, and a table of all grants sorted by date*

or

*Turn this spreadsheet into a dashboard with charts. I want to see trends over time and be able to filter by \[COLUMN NAME\]*

or, if you want to keep it simple:

*Build a dashboard from this data: \[paste your table here\]*

Your agent will create a local web app—likely a single HTML file or a small project with a few files. It'll open in your browser so you can see it right away.

Step 2: Iterate

The first version is rarely perfect, and that's fine. Tell your agent what to change:

Make the colors less garish Add a pie chart for the status breakdown The numbers should show as currency Make it look more professional—I'm going to share this with our board

Step 3: Put it online

Once you're happy with how it looks, publish it so anyone with the link can see it:

*`/deploy-with-vercel`*

Your agent will deploy the dashboard and give you a public URL. Share it with your team, your board, or your funders. No server to maintain—it just works. If you want to make any changes, just make sure you run /deploy-with-vercel afterwards so the webpage is updated as well.

# End

**Session wrap-up**  
We hope you found this helpful and informative. Please give us some feedback on this 2 min questionnaire:

[https://docs.google.com/forms/d/e/1FAIpQLSc32BMJrw3WtvJhXHX-3BeUPw1QJAgGJvwOHNqVkozlgZWmxQ/viewform](https://docs.google.com/forms/d/e/1FAIpQLSc32BMJrw3WtvJhXHX-3BeUPw1QJAgGJvwOHNqVkozlgZWmxQ/viewform)

This will help us tailor the session better to suit the needs of future EAs going through this session  


[image1]: <data:image/png;base64,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yxQqa8aEBWYprVLi+tKXvlTVz0fH3nrrraKmdOLnve2221hN7ZKV1SlHXFggjiX5PsxL+KfITz75pCxOkzxe9k31sl2l6ctf/rLT95EjR0x5rfrPS/KPQ97r/Nxzz5lr+vrXv25yOASpmussemxNxUUJg4in733ve+rAgQNGbENDQ+kvhD75QzRGZadOnXKOpYS25YjrlltuUatWrUrL+BuM2mD/kUceScsef/xxU/bMM8+kZddff71XRn09//zzaRm92SBofh55XiTqM/6zhqeLeUmep6enRz3xxBOp0Pbs2ZO2w310sj1t87If/vCHZv/pp59Oy+69917nZ6d+QsdT+c9//nOzT9dErxW90bds2eJdj0xWWhx8eixb2YR+5KfKsetD2r59e/o+oPcFrlG2wz9P5sfL9znV4X2O1wf7iD7a29vN9je+8Y207YMPPmjK7rjjjrSMEj83Uuja6T00ODjo1cltsGbNmnQf7wXehicprVKvM08UtaL8Rz/6kckfeuihtB5/FFF29913p2XYx8/yrW99K71Wilzl7+KVV14xIDVcXPTD4o1F2/KFjqVyxLVhwwavX9rfu3dvuo0Xbfny5cHrgfwOHTrklCGnaS+V4VxLliwx2/QL4PV8O9RnKElp5YkLbw5cA/4y33777aasu7s7eH7k9EbYtm2bd62UQ1o33XRTWoZr/v3vf2/ExdvFtpEfO3bMKePXFHq9IfLYazKcyAr5sMknzS0loRTqQ56Lb3Nxxa4Pg1L2K9/nVI/3OSRHZS+++KJTj98XohSkhx9+2ItSS4kLv5f169cH62TZ8PCwV4briyV6bTmx15nGMyIvnlCGAIW2Kac/dt/5znfMOOD1lGifv970u4C0aCmCicuXUx55Sf5Cubi6urrScv5D4ZeFkD0vlSsuug5MVbnIvvKVrxir//rXvzbw68CApfSLX/zClMl1G0QOTz31lHMcT7xcnoP6LPWzSmnliYufn7YhCUiU0p133qm2bt2ae62hXCZ83/SFF14InpNvy+NfffVVc02PPvpoWsbbYiCPjIykdTJZYbnEBpQ8Ny8LXSsX18GDB9N6SmgX6lO+z6kNFwM/7pvf/GZaRu8L/t6gJKeKUgJIR48eNdErla1duzaNbLmE6Rxf/epX07K8JKWVJy5KOC/6pRkOPweWimQZ34+VL1q0yPtdTKm4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>

[image2]: <data:image/png;base64,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>