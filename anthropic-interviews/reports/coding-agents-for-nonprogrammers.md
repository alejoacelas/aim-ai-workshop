# Non-programmers using coding agents and tools

An analysis of the AnthropicInterviewer dataset, focusing on how professionals outside software development are using AI-powered coding tools to build software, automate tasks, and expand their capabilities.

---

## 1. Executive summary

Across 934 transcripts filtered for mentions of coding tools (Cursor, Copilot, Claude Code, vibe coding, etc.), a meaningful subset reveals non-programmers---from recruiters and lawyers to workshop designers and regulatory consultants---who are using AI to write code they could never have written themselves. These individuals don't aspire to become programmers. They want to solve specific problems: automating a tedious document conversion, building a holiday tracking system, generating PowerShell scripts to save colleagues 10--14 hours per week, or creating interactive training materials with embedded augmented reality.

The emotional texture of these experiences is strikingly different from how professional developers describe the same tools. Non-programmers talk about "breakthroughs," feeling "immersed in the future rather than left behind by it," and moments of genuine amazement when code they couldn't write themselves runs for the first time. They use metaphors of language immersion rather than pair programming. They are less concerned about skill atrophy and more concerned about the intimidation of even knowing where to begin. Their frustrations are also distinct: where developers complain about context window limits and deprecated package suggestions, non-programmers get stuck in loops where the AI proposes solutions that don't work and they lack the knowledge to diagnose why.

The most consistent finding is that AI coding tools are functioning as a new kind of literacy enabler. Just as word processors didn't make everyone a professional writer but gave everyone the ability to produce documents, coding agents are giving non-programmers the ability to produce functional software---not as a career, but as a means to solve problems in their actual domains of expertise.

## 2. Who are the non-programmers using coding tools?

The non-programmers found using coding tools in this dataset span a wide range of occupations:

**Technical-adjacent roles (some coding exposure, not primary skill):**
- Technical integration engineer at a college (work_0173)
- Design Technology Manager at an architecture firm (work_0974)
- IT support specialist (work_0497)
- Business analyst working on cricket software (work_0658)
- Quality engineer (work_0967)

**Business and management roles:**
- Medical device regulatory consultant / solo-preneur (work_0096)
- Canadian telecommunications lawyer (work_0450)
- Credit union manager (work_0741)
- Product Manager at a UK regulator (work_0831)
- Recruiter and small business partner (work_0594)
- Project Manager at a fintech company (work_0615)
- Tech startup founder / project manager (work_0310)

**Creative and communication roles:**
- Freelance copywriter with 44 years of keyboard experience (work_0212)
- SEO specialist / freelance writer (work_0708)
- Workshop designer and facilitator (creativity_0022)
- Non-developer in a product demo role (work_0108)

**Research and academic roles:**
- Neuroscience research operations manager (work_0376)
- Mathematician / research scientist at a mining software company (science_0061)

A recurring demographic pattern: many of these individuals are mid-career or senior professionals who have deep domain expertise in their fields but limited or no formal programming training. Several explicitly describe themselves as "not a developer," "non-technical," or say they "don't know how to code."

> "the AI adds value for me because I don't know how to code well.  I made minor efforts to try to learn over the years, but was always stopped along the way."
> --- work_0974

> "I don't need to know code, so I'm not particularly worried about that. I also feel that as a business analyst, one of my core skills is elicitation and communication skills - something that AI is not able to do at the moment"
> --- work_0658

> "I have about three decades of mental scar tissue to remove as far as tech is concerned, I've always considered myself a 'humanities guy' and ignorantly swanned off"
> --- work_0594

## 3. What are they building?

Non-programmers are not building ambitious software products. They are building **targeted solutions to specific workflow problems** they encounter daily:

**Automation scripts and data processing:**
- A groovy script saving coworkers 10--14 hours per week of manual work (work_0173)
- PowerShell scripts for batch processing (work_0173, work_0019)
- A Python app for document formatting and file type conversion, turning a 6+ hour manual task into a 1-minute automated process (work_0108)
- PowerQuery code for data manipulation (work_0658)

**Internal tools and utilities:**
- pyRevit tools for architectural workflows---creating scope box analyzers, level generation scripts (work_0974)
- VBA macros to automate batch editing of specification documents (work_0974)

**Websites and web applications:**
- WordPress sites with custom CSS (work_0708)
- A semi-interactive website using HTML, CSS, and JavaScript (work_0212)
- Service area pages for small business SEO clients (work_0708)
- Sites built from scratch versus page builders (work_0708)

**Interactive training and content:**
- AR-enhanced interactive training materials using Thinglink (creativity_0022)
- Educational presentations and ebooks (creativity_0022)

**Data analysis and reporting:**
- Image grid generation for dental x-ray reports (work_0096)
- Equipment comparison charts and vendor analysis (work_0376)

> "I recently used AI to write a little app that makes massive formatting changes to different documents and then leverages an open source python module to convert the doc to a different file type. I was able to get the app up and running in about an hour. The app takes about 1 minute to run. I think it probably would have taken me 6+ hours to make the changes to these docs myself."
> --- work_0108

> "I recently was able to use AI to help me write a groovy script to accomplish a task that was costing folks in my department many hours a week and had it teach me groovy along the way."
> --- work_0173

## 4. How do they describe the experience?

Non-programmers use a distinctive set of metaphors and emotional language when describing their coding-with-AI experience. Their language reveals both wonder and vulnerability in ways professional developers rarely express.

**Language immersion metaphor:**

The most striking metaphor comes from an SEO specialist who compares learning code through AI to learning a foreign language:

> "It's almost like how if you plop someone down in Italy for a long time, eventually they'll pick up on the language. While I don't know how to write a lot of code from scratch, I can read it and edit it myself once it's written. Does that make sense?"
> --- work_0708

**Capability expansion language:**

Non-programmers consistently frame AI coding tools as enabling things they *couldn't do before*, not just doing things faster:

> "First of all, I didn't have to code anything which was excellent because I don't code at the level needed to produce interactive files. AI took care of that for me."
> --- creativity_0022

> "In the past, I had to 'dumb down' many of the things I wanted to produce because either the tech wasn't readily available or I didn't have the knowledge to use it effectively."
> --- creativity_0022

> "what I love about AI is it bridges that gap that has built up over the years, it's reactivated dormant skills I thought had sadly consigned to the past, and I feel quite immersed in the future rather than left behind by it."
> --- work_0594

**The car analogy:**

> "I think that there are certain things that won't be required and I am ok with that. Just like I drive a car but have no idea how it works."
> --- work_0173

**The manager metaphor:**

> "It sometimes is time consuming to find the right one for the job and remember how to interact with each for the best outcome. It's kind of like I am a manager and I have a team of reports-to that are all the AIs."
> --- work_0173

**Amazement at scale:**

> "It was amazing.  All in all, it probably took about 30 minutes of effort, and the output was easily over 100 lines of code.  When I told my boss (the Design Technology Director) about it, she was impressed, and that felt awesome too."
> --- work_0974

## 5. Barriers and frustrations

Non-programmers encounter a distinct set of barriers that differ significantly from those experienced by professional developers.

**The debugging wall:**

The most common frustration is reaching a point where AI-generated code doesn't work and the user lacks the knowledge to diagnose the problem. Unlike professional developers who can read error messages and debug, non-programmers are dependent on the AI to fix its own mistakes---which it often cannot do.

> "vibe coding has also lead to some of my biggest frustration where the solutions AI offers are overly elaborate and I have to guide it back to something reasonable. This recently happened on a PowerShell script I needed help on where it told me the outcome was not possible so I went on my own for awhile and brought my idea and current state of work back to the AI where it acknowledged the pathway as viable and helped me finish it."
> --- work_0173

> "I was unable to find code to perform the smoothing so I had to come up with my own. However, with the help of AI, I was able to in one day start with the paper, read it, and chatting back and forth with chatGPT come up with the code to my problem."
> --- science_0061

A mathematician describes the vibe coding failure mode:

> "I went back and forth for hours if not days with you Claude about creating a small app in Python/Trame. it was my first attempt at 'vibe coding', where I simply trusted the AI to give me the final product and I had little interest in the inner workings. Alas, after a long time, I had to dig in myself and google lots of things, when I just wanted the app as if waving a magic wand."
> --- science_0061

**AI failing non-technical users on simple tasks:**

> "My non-technical coworkers used a particularly famous AI to adjust their plain HTML webpage code to remove a paragraph from a column (inner div) and have the paragraph formatted outside the column as a stand alone portion of the webpage. The 2 coworkers spent a lot of time with that AI trying to fix this issue but it could not get it done despite the code being fed to the AI to edit it."
> --- work_0019

**Integration and access barriers:**

Non-programmers struggle with the overhead of even getting started with coding tools. The workflow of copying code into files, running it, and pasting errors back is foreign and cumbersome.

> "Right now, AI isn't truly integrated into anything I do. I stop my work, open the web app, and then type in what I need, upload, etc. I would love to learn how to make agents or something that is more integrated."
> --- work_0096

> "I am a solo-preneur, and small business owner who is also doing all of my own consulting, so I am very cautious with my time. And I have not yet found a way to enhance my skills in a way that I am willing to commit to."
> --- work_0096

**Volume and context limitations:**

> "I find that both limit my uploads, so I struggle with the volume of documents. That is why I have started to use Notebook LLM. Although, I don't like notebook LLMs output the best, it allows the most volume."
> --- work_0096

**The intimidation factor:**

> "even understanding the terrain is a bit intimidating, let alone what I need to do within it."
> --- work_0594

## 6. Success stories and "aha moments"

The most powerful success stories come from moments where non-programmers accomplished something they genuinely believed was impossible for them.

**The groovy script breakthrough (work_0173):**

A technical integration engineer at a college, who self-describes as not being a programmer, used AI to write a groovy script that saved colleagues an enormous amount of time:

> "I recently was able to use AI to help me write a groovy script to accomplish a task that was costing folks in my department many hours a week and had it teach me groovy along the way. On the flip side, vibe coding has also lead to some of my biggest frustration"
> --- work_0173

> "I would never have been able to create the groovy script saving my coworkers 10-14 hours every week without it."
> --- work_0173

**The architecture tools (work_0974):**

A Design Technology Manager at Rockwell Group, an architecture firm, who admits he doesn't "know how to code well," has been building custom pyRevit tools using AI:

> "This has added value because I know the kinds of tools I want to create and use, and I have the ability to describe these tools using natural language.  I think you can tell from these conversations that I have the ability to write well, and that I value comprehensiveness.  My ability to naturally describe the things I want in detail make up for the shortfall in my technical ability to create these solutions myself."
> --- work_0974

**The document automation (work_0108):**

A non-developer who builds product demos used AI to create a document processing app:

> "I recently used AI to write a little app that makes massive formatting changes to different documents and then leverages an open source python module to convert the doc to a different file type. I was able to get the app up and running in about an hour."
> --- work_0108

**The recruiter's feedback loop (work_0594):**

A recruiter, self-described "humanities guy," used AI to break into an unfamiliar sector:

> "Long story short, got an intervew within the hour for a role that we can charge three times as much for, in a role we don't really fully grasp yet, and I'm awaiting the results of the final interview right now!"
> --- work_0594

**The workshop designer's creative liberation (creativity_0022):**

> "Five years ago if you had told me I could produce training files with imbedded augmented reality easily, I definitely would be skeptical. Now, things have really changed."
> --- creativity_0022

**The lawyer's proposal acceleration (work_0450):**

A Canadian telecommunications lawyer compressed a week's work into a single day:

> "It is the kind of proposal that, in the past, would have taken me several days to a week to prepare given the complexity of the matter an the client's specfiic requirements.  However, because I had some extensive rough notes, I was able to upload my notes directly from [REDACTED] into Copilot's Researcher agent and generate a proposal to the client that was around 80% complete in 10 minutes."
> --- work_0450

**The microscopy equipment negotiation (work_0376):**

A neuroscience research operations manager used AI to navigate vendor negotiations:

> "Ultimately, we were able to save tens of thousands of dollars with this method, and purchased equipment that many of our users were very happy with!"
> --- work_0376

## 7. Comparison: how programmers vs. non-programmers describe the same tools

The contrast between how professional developers and non-programmers describe the same AI coding tools reveals fundamentally different relationships with the technology.

### Mental models

**Programmers** use collegial or hierarchical metaphors. They see AI as a junior developer, a pair programming partner, or a tool in their existing workflow:

> "My mental model of claude code is that it is an eager but very junior developer, and our conversations are like pair programming, with me calling the shots, reviewing and approving each step."
> --- work_0221 (software developer)

> "I use the term 'vibe code' derisively; to me it means a naive layman letting the machine do all the work."
> --- work_0221 (software developer)

**Non-programmers** use metaphors of liberation, bridging gaps, and capability expansion:

> "what I love about AI is it bridges that gap that has built up over the years"
> --- work_0594 (recruiter)

> "AI definitely removes technical barriers (and I like tech!) that are frustrating/difficult and provides a way to enhance creativity so I am better able to meet my creative objectives."
> --- creativity_0022 (workshop designer)

### Relationship to code quality

**Programmers** care about code quality, maintainability, and understanding what the code does:

> "I would prefer to code everything myself. If I let Ai do everything then I won't know the details of the system and I wont be able to fix bugs."
> --- work_0365 (developer)

> "I'm ok with ai writing 100% of the code as long as I know how it works"
> --- work_0365 (developer)

**Non-programmers** care about whether it works, period. The code itself is a means to an end:

> "I'm not a developer so it usually looks like me requesting the AI create an app. Once the AI has given me the code, I will run it. At this point I usually encounter errors."
> --- work_0108 (non-developer)

> "it was my first attempt at 'vibe coding', where I simply trusted the AI to give me the final product and I had little interest in the inner workings."
> --- science_0061 (mathematician)

### Skill atrophy concerns

**Programmers** actively worry about losing their edge:

> "I worry about AI taking over quite a lot, but its aptitude for certain areas does make me feel like not being good at those areas maybe doesn't matter too much."
> --- work_0227 (software engineer)

> "Well, I think its eventually leading to a shrinking of my industry and unemployment for me."
> --- work_0221 (software developer)

**Non-programmers** don't worry about losing coding skills they never had---they worry about being left behind by not knowing *enough* about AI:

> "I feel that I need to develop skills in this area or I will get left behind, especially over the course of a career."
> --- work_0831 (product manager)

> "I am less concerned about AI fully taking over because I think you need a human to deal with other humans, especially in my role. However, I am concerned about humans with better AI skills out competing me."
> --- work_0831 (product manager)

### Verification approach

**Programmers** review code line-by-line and test systematically:

> "usually issues of style. i am surprised by how few errors claude code makes, especially compared to generating code from prompts on the web browser."
> --- work_0221 (software developer)

**Non-programmers** test by running the code and seeing if it works, often unable to diagnose failures:

> "I paste the code output into the script.py file VSCode, which is located in the folder hosting a toolbar, panels, and pushbuttons of test scripts.  I run the script, and it rarely ever nails it on the first try."
> --- work_0974 (design technology manager)

## 8. Key quotes collection

### On identity and AI

> "I have about three decades of mental scar tissue to remove as far as tech is concerned, I've always considered myself a 'humanities guy' and ignorantly swanned off, now I'm looking for easily remedied angles where I fall short"
> --- work_0594

> "Look, I'm old. I have worked using a keyboard for 44 years. I enjoy writing, and I enjoy researching new things."
> --- work_0212

> "I still want to be able to think and create. I appreciate what AI can do for my productivity at work, but being able to just do human things is important to me."
> --- work_0108

### On coding with AI as a non-programmer

> "Coding is hit or miss, but to be honest, that could be because of my lack of coding knowledge. As someone who has very little, it's still much better than I am."
> --- work_0708

> "I don't know how to code, or to use PowerQuery, so when I asked the AI to create code for me to simply do what I wanted it to do, I found it very effective."
> --- work_0658

> "It is hard to take python or groovy classes that teach everything but without application it doesn't stick."
> --- work_0173

> "My ability to naturally describe the things I want in detail make up for the shortfall in my technical ability to create these solutions myself."
> --- work_0974

### On vibe coding and its risks

> "I started vibe coding and it was going really fast and I was loving it. I was letting ai do most of the work (lesson learned) and after like a week, I basically couldnt work on the project anymore because I had no idea how anything worked."
> --- work_0365

> "god dammit, i vibe coded this thing and it's broken and i'm not sure how to fix it"
> --- work_0221

> "if I don't know how to code, or to use PowerQuery, so when I asked the AI to create code for me to simply do what I wanted it to do, I found it very effective. Minor finetuning was required, but it ended up saving me a lot of time"
> --- work_0658

### On the emotional experience

> "it's reactivated dormant skills I thought had sadly consigned to the past, and I feel quite immersed in the future rather than left behind by it"
> --- work_0594

> "In the past, I had to 'dumb down' many of the things I wanted to produce because either the tech wasn't readily available or I didn't have the knowledge to use it effectively."
> --- creativity_0022

> "I prefer to show, not tell, he is certainly curious about how I am managing to suddenly do the job of three admins at the drop of a hat!"
> --- work_0594

### On trust and verification

> "I can only think of one example where I was really impressed and just couldn't believe how well it worked."
> --- work_0096

> "I have many of being frustrated, unfortunately, as that is most of my interactions."
> --- work_0096

> "I rarely assign it tasks due to trust issues."
> --- work_0173

### On the future

> "I imagine in 5 to 10 years I'll be a one-man agency with a few competent AI agents that handle tasks for me."
> --- work_0708

> "If/when the AI companies develop more 'integrate-able' solutions, for laypeople like me, I will adopt them. I look forward to that day"
> --- work_0096

> "I think more energy should be spent (although I don't know that it isn't already done so in traditional work settings?) on training people to use AI as an assistive tool, rather than always doomsaying that is taking away jobs."
> --- work_0212

### On workplace dynamics

> "One coworker doesn't even seem to think for himself anymore, as he relies on AI for everything. This has actually made me want to use AI only when necessary, interestingly enough."
> --- work_0108

> "I deeply regret admitting that I used certain tools in certain circumstances, as I felt some people in the organization used it against me behind closed doors."
> --- work_0243

> "I suspect using Claude code is against company policy, but it is so effective that i super don't care."
> --- work_0221

---

*Analysis based on 934 transcripts from the AnthropicInterviewer dataset. Approximately 15--20 transcripts were identified as featuring genuine non-programmers discussing their use of AI coding tools, with an additional 10+ programmer transcripts analyzed for comparison.*
