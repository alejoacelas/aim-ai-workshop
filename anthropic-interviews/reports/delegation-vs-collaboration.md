# How non-programmers decide what to delegate to AI vs. collaborate on

An analysis of delegation and collaboration patterns among non-technical professionals, drawn from the AnthropicInterviewer dataset (989 transcripts, filtered for non-programmer occupations including teachers, writers, designers, managers, accountants, lawyers, therapists, marketers, and others).

---

## 1. Executive summary

Non-programmers who use AI tools at work have developed remarkably consistent intuitions about what to hand off and what to hold onto. The central finding across these interviews is that delegation decisions are not primarily about task difficulty or AI capability---they are about **stakes, identity, and detectability of errors**. Professionals delegate tasks where mistakes are easy to spot and cheap to fix (email drafting, formatting, brainstorming), while retaining control over work that is high-stakes, relationship-dependent, or core to their professional identity.

The most common mental model is AI-as-junior-colleague: an intern, a teaching assistant, a research assistant. This framing is not merely metaphorical---it structures the entire workflow. People give AI bounded tasks, review its output, and reserve judgment calls for themselves. Even those who are enthusiastic about AI and see it as transformative describe a persistent verification reflex. The phrase "trust but verify" appears in spirit, if not in exact words, across nearly every interview.

What distinguishes the most sophisticated users from beginners is not *how much* they delegate, but how precisely they have mapped the boundary between what AI does well and where it fails in their specific domain. A paralegal knows AI hallucinates case citations. An accountant knows AI botches nuanced billing codes. A chef knows AI cannot convert baker's percentages reliably when eggs are involved. These professionals have calibrated their trust through direct, sometimes painful, experience---and their delegation patterns reflect that hard-won knowledge.

---

## 2. A framework for delegation decisions

Five factors consistently determine whether a non-programmer delegates fully, collaborates, or retains full control.

### 2.1 Error detectability

The single strongest predictor of delegation is whether the person can quickly tell if the AI got it wrong. Tasks with immediately visible errors get delegated more readily; tasks where errors are subtle or hidden are kept close.

> "things that very detail oriented, or moving a lot of data around, or are numbers-heavy, are tasks i just do myself, though i would love to have ai do it for me. perhaps it's just i don't have the knowledge to interact with the ai appropriately. I don't know what it's capable of, so i just do it myself to avoid creating more work for myself. the tasks that i can quickly tell whether or not there's an issue (copy writing, emails, simple taks), are the ones i lean on ai more."
> --- work_0894

> "I prefer to use AI to get a general idea and if things aren't as important.  If serious issues come up, I may still use AI to get some data analysis but I will also be double checking the information myself to ensure nothing is missed."
> --- work_0022

### 2.2 Consequence severity

When errors carry real-world consequences---financial, legal, reputational, or medical---professionals retain control regardless of AI capability.

> "I do prefer the handle my bookkeeping and invoicing tasks by myself.  As an accountant, I am a stickler for accuracy in my accounts and so I have not yet developed enough trust in AI to let it take over that that task.  I would prefer to verify accuracy of the balances due and not have to deal with sending out an incorrect billing as that does not go over well with the customer."
> --- work_0132

> "When I read contracts, I sometimes ask for summaries but still prefer to go over them myself out of fear of AI hallucination when it comes to more sensitive material."
> --- work_0514

> "I also do data entry which directly affects how healthcare professionals get paid, and there can be no mistakes or the claims will be rejected.  I would like to maybe one day use AI for this, but currently it is too vital to entrust to AI as there is too much nuance to the entries."
> --- work_0022

### 2.3 Relationship and authenticity demands

Work involving personal relationships is almost universally retained. The closer the recipient is to the professional, the less AI involvement is tolerated.

> "Client and colleague emails sound more authentic when written by humans, especially when recipients are already familiar with your style of writing and tone."
> --- work_0514

> "When it comes to tasks, I like using AI to replace the parts of my mind I don't feel attached to. Formal writing, for example, where you have to speak robotically anyway, I'm like, go ahead. Calculations, too. Busy work, grunt work, crunching information. That stuff I let AI do. But things like texting family, or writing for fun, I do myself. I suppose it comes down to tasks that involve emotion or passion."
> --- work_0745

> "Getting to build rapport with clients and potential clients is rewarding and gives a break from deep work stuff so I like to keep a certain level of communication strictly human input only."
> --- work_0838

### 2.4 Professional judgment and expertise

Tasks requiring domain-specific judgment are the last to be delegated. Professionals see these as the irreducible core of their value.

> "I would feel quite uncomfortable with using AI to create a lesson plan and schedule. I may ask for example sub-topics or problems, but I absolutely wouldn't use it to create, say, the main take-aways the lesson should have."
> --- work_0102

> "the part of producing I love is the networking with financiers, negotiating with vendors, and negotiating with / hiring cast and crew...those are all things that need the human touch for sure."
> --- work_0510

> "I work on tasks together. I have to verify everything I do myself. I am handling payments and money and its critical that I understand what I'm doing. I may have AI do the 'heavy lifting' and I will ask follow up questions and for clarification and more nuances to be added throughout. I never say 'here do this' and then just trust that it is all correct."
> --- work_0982

### 2.5 Learning opportunity cost

A surprising number of professionals deliberately avoid delegating tasks they want to get better at, treating manual work as a development opportunity.

> "The tasks I like to leave for myself to do are ones that will be most beneficial for my continued professional development in my current role and I typically do not rely on an AI tool to help me complete those projects unless I get stuck on something or could ask for any useful suggestions from the tool. The types of tasks I like to utilize without the use of AI are more project-management related because this is an area that I could use with more fine-tuning, practice with incorporating it into more of my workflows day-to-day. If I were to utilize AI to take care of all that work for me, I would lose the opportunity to make calculated mistakes and learn from them to ensure they dont repeat themselves in the future."
> --- work_0333

> "I read a story recently in the news that doctors lost diagnostic skills after relying on AI to do it for a while.  I need to keep growing my skills."
> --- work_0593

---

## 3. Trust dynamics

### 3.1 What builds trust

**Consistent accuracy over repeated use.** Trust is built incrementally through successful interactions, not through any single impressive demonstration.

> "I think, in time, I could come to trust AI more as its accuracy and understanding of my systems grows."
> --- work_0132

> "For me, the tipping point was when the AI models started 'remembering' past conversations. It's very helpful when the model knows what I've tried, what I've dismissed, my voice and my goals. The conversation can be productive from the first prompt in a new conversation."
> --- work_0527

**Ability to show its work.** Professionals trust AI more when they can trace its reasoning or verify against sources.

> "I try to only use it in ways I can verify on my own, so I don't fall prey to hallucinations."
> --- work_0593

> "I'm still not 100% convinced of AI's ability to produce factual information consistently, so I use it to bring up sources that I can fact check myself against its claims."
> --- work_0255

**Workplace normalization.** Seeing colleagues use AI successfully lowers the barrier significantly.

> "My colleagues have sought assistance from different AI models in their daily tasks, which has made me feel more comfortable in doing so."
> --- work_0008

> "I have another job at a brewery where AI is being incorporated more, so I kind of see the applicatios they're using it for and I guess it makes me feel more comfortable bringing it in at my own business."
> --- work_0255

### 3.2 What erodes trust

**Hallucinations.** Nothing destroys trust faster than AI fabricating information, especially in high-stakes domains.

> "I was getting it to help me with a specific legal task quite recentyl, and I'd given it all the documents to work with, and it hallucinated a case and I almsot hadn't noticed. it was pretty frustrating because the implciations of that owuld have been huge. even the best models now are still hallucinating cases which really damages trust especially int he legal profession."
> --- work_0143

> "there have been times when (unfortunately) the ai hallucinated comments--it made them up instead of pulling from the file. when fact checking the comments, they weren't actually in the chat transcript."
> --- work_0894

**Inability to stay on-task.** When AI persistently misunderstands the assignment despite repeated correction, trust degrades rapidly.

> "I have had some frustrations with AI when I tried to have it set up a marketing plan and it went completely off course with ideas that did not match what I had requested."
> --- work_0132

> "I asked for a plan that would be suitable for reaching customers with older vehicles, since we are not a dealership and therefore our customers are those who own cars that are no longer under warranty.  AI was determined to focus on new or almost new cars that do not fit our business model."
> --- work_0132

**Witnessing others' failures.** Secondhand stories of AI failures are powerful trust-eroders, even when the person hasn't experienced the failure themselves.

> "A real estate team was selling a property that was fully described by an AI assistant and there seems to have been no human oversight. When the property went online, people started visiting... But quickly they realized that the great school that was advertised as being in proximity was not even close. It was in a different municipality."
> --- work_0514

> "I have seen my colleagues misuse AI and suffer consequences, so I learned early that I need to validate output and consider where and how I can best leverage the technology."
> --- work_0130

---

## 4. Override patterns

Professionals describe several recurring situations where they take back control from AI.

### 4.1 The voice override

The most common override occurs when AI output doesn't match the person's voice, tone, or style. This is near-universal among writers, marketers, and anyone in client-facing roles.

> "I like to re-edit the suggestions I receive to ensure they align with my style and tone, and my preference for a localised Kiwi-business-casual style"
> --- work_0255

> "Most often, it's to sound less like a sales pitch. To keep the communication friendly and casual."
> --- work_0527

> "Sometimes, they models will make me sound TOO kind, which is probably appropriate most of the time, but it doesn't match my voice. It will also reel a joke in sometimes if it's 'on the edge', and I'll evaluate it."
> --- work_0383

### 4.2 The accuracy override

When AI produces content that must be factually precise, professionals default to manual verification or takeover.

> "I always get frustrated when making dough recipe books. I'll have a big list of recipes in bakers percentages that I want converted to a set size, and I've learned the hard way that I need to double check every recipe provided by the model or just do it myself beforehand."
> --- work_0383

> "The calculations are sometimes wrong, so having to double check or verify. This ends up taking too much time, I could just do it myself in less time."
> --- work_0408

### 4.3 The "felt wrong" override

Several professionals describe a gut-level discomfort when AI handles certain tasks, leading them to redo work even when the output was adequate.

> "I tried asking a model to build a daily course schedule for me for a new semester from one I had built for the previous year--basically just change the dates to the new semester.  But as soon as it did so I felt that I didn't have a feel for the schedule and I was uncomfortable without having gone through the process myself."
> --- work_0593

> "I think it was about being reflective and 'closing the loop' as we call it in assessment.  If it had just been purely a matter of shifting dates but otherwise keeping to exactly the same schedule I might no have minded as much.  But I found I wanted to give some lessons more time, some lessons less.  I wanted to add a lab activity, but I needed to figure out how to make room for it.  I just needed my own hands on the wheel, so to speak."
> --- work_0593

### 4.4 The productivity override

When AI creates more work than it saves, people quickly revert to manual methods.

> "now i'm a bit hesitant because it ends up causing more work for us. if the ai is unreliable and i'm having to spend time fact checking, it's counter productive."
> --- work_0894

> "i don't do too, too much data management, but there have been times i've combine some order exports or membership reports. honestly, i probably haven't implemented more ai assistance because i'm fearful that it will make a mistake and i'll have to just do it myself, so i end up just doing it myself to avoid the risk and wasted time."
> --- work_0894

---

## 5. The delegation spectrum

Based on patterns across the interviews, tasks fall into five zones from fully delegated to never delegated.

### Fully delegated (minimal review)
- Spell-checking and grammar correction
- Reformatting and file renaming
- Summarizing meeting notes
- Generating hashtags and SEO metadata
- Text-to-speech narration

### Mostly delegated (light review)
- Drafting template emails and form letters
- Creating first-pass research summaries
- Scheduling and calendar organization
- Data formatting and cleanup

### Collaborative (substantial human involvement)
- Writing marketing copy and web content
- Brainstorming and ideation
- Script breakdowns and production planning
- Analyzing data trends and generating reports

### Mostly human (AI as second opinion)
- Lesson planning and curriculum design
- Contract review
- Client communications
- Creative writing and storytelling
- Financial analysis and budgeting

### Never delegated
- Final judgment calls (hiring, grading, medical decisions)
- Relationship-building conversations
- Core creative vision and artistic direction
- Sensitive personal communications
- Work involving confidential/PII data

> "The financial tasks are cut and dried. They're either right or their wrong. My voice and vision don't matter in those tasks. For the writing tasks, they still reflect me. It's [REDACTED] photography I'm selling, not AI's."
> --- work_0527

> "For the novel is was an assistant while I did the work. For my direct sales business the more it can do for me the better."
> --- work_0013

> "I did not want AI writing the book for me. I only wanted it as an assistant. I believe it's a mistake to let AI do entire tasks in the creative arena. It would not have truly been my novel if AI had written it for me."
> --- work_0013

---

## 6. Emotional and identity aspects

### 6.1 The craftsperson's tension

Many non-programmers experience a genuine tension between efficiency and craftsmanship. Delegating routine work feels sensible, but delegating anything tied to their skill set provokes discomfort.

> "It is something I consider. I've always prided myself on my command of the English language and general communication skills, and this probably informs my refusal to relinquish the editorial oversight I retain."
> --- work_0255

> "When it comes to anything deeply creative, like developing my story or creating prose, I don't want any sort of collaborator. I don't want ideas from the AI to get into my head. The whole point of writing is to do it myself."
> --- work_0302

> "Even if I had full trust in the model, I think I would need to keep things collaborative as a creative output. I look cooking, and I like creating dishes. If I was just plugging requests in to a machine and following recipes, I'd probably do something else."
> --- work_0383

### 6.2 The laziness stigma

Multiple professionals express anxiety about being perceived as lazy for using AI---or perceive others as lazy when AI use is visible.

> "I would say its around a 50/50 split. As I use AI quite a lot, and see a lot of emails and copy from businesses, I feel I can now tell very easily and quickly if something has been written by AI. So I always try to tailor my emails at least a little so it doesnt seem its been written by AI without any editing whatsoever, as I feel this just makes you look lazy."
> --- work_0445

> "When I see that something is clearly just copy pasted from an AI model I get put off. To me, personality shows care and pride. If you aren't putting any effort in to your menus or website, can I trust you to care about the food you put out?"
> --- work_0383

> "I can absolutely tell when other creators incorporate AI into their copy and to be honest I have mixed feelings about it. Without any edits, it seems really lazy."
> --- work_0387

### 6.3 Fear of deskilling

The worry about losing skills through over-reliance on AI is widespread, particularly among educators and writers.

> "We work with youth, and we recognize that recent studies have shown that AI basically reduces brain connectivity and general critical thinking and creativity. I even feel that a bit myself. In the same way that boredom forces creativity, not having AI forces brainstorming and critical thinking and research."
> --- work_0102

> "I just feel as though when I am using the ai I am not actively using my brain to find better words or ensure my grammar is the best it can be"
> --- work_0579

> "it does cross my mind occasionally that i should still at least flex those muscles so as not to get too rusty when it comes to tasks i pass off to ai. to stay sharp and to not be tooooo reliant on it."
> --- work_0894

### 6.4 Professional identity and replaceability

Most non-programmers have worked through the "will AI replace me?" question and arrived at a position of conditional confidence, anchored in the human elements of their work.

> "With sales, the personal touch and relationships are PARAMOUNT. AI can never replicate who I am or the way I make people feel heard, understood, and comfortable."
> --- work_0387

> "I don't think an AI chatbot (as they exist currently) could effectively replace the human interactions that constitute a healthy learning community. I certainly try to sharpen my ability to respond to student work, but I don't think any students would desire a classroom taught by an emotionless chatbot."
> --- work_0598

> "My clients have come to me because they trust in MY abilities. If they just wanted AI generated content, its plausible they could do that on their own."
> --- work_0733

> "I do. All the time. As I see AI assistants becoming better and better at writing, ads, strategy, visuals, translation... I realize that from the moment they're able to synthesize everything on their own, they will technically have the ability to replace me. But today by collaborating with AI, I still feel like I'm in the driver seat."
> --- work_0514

---

## 7. Evolution over time

### 7.1 The typical trajectory

Most professionals describe a consistent arc: initial excitement or skepticism, followed by experimentation, then calibration based on direct experience with failures and successes, leading to a stable and domain-specific delegation pattern.

> "My workplace culture has changed a lot over the last two years to go from wary of AI to trying to integrate it more and more. A lot of the initial skepticism has worn off. I feel more comfortable using it now."
> --- work_0066

> "Before we had openly embraced this I wouldn't say apprehensive but I didn't see the benefits at the time in using AI. Now I view it as a tool to use and collaborate with to make me more productive and a valued asset with the teams I work with"
> --- work_0052

### 7.2 Delegation expansion follows demonstrated reliability

People don't expand delegation based on abstract capability claims. They expand it only after direct, repeated success in progressively higher-stakes tasks.

> "It would be wonderful if AI could take over more of my tasks, including those that require more skill.  That said, I would still prefer to be involved in overseeing what AI did before giving it the stamp of approval.  I see myself as always proofreading the work that AI does."
> --- work_0132

> "I think fairly soon, AI will take over the 'math' tasks. It's already integrated in my photo editing programs. Eventually those will need less input from me. I see a future where my editing program can access all my photos, learn my goals, what I like and instantly edit my photos in my style. To me, that's a great use of AI."
> --- work_0527

> "I hope it keeps going the way it is, with more productive collaboration.  I do, however, hope that the AI grading helpers that are being developed get truly good at some point.  I'll happily delegate that work (with supervision, always) to an AI if it did a good enough job (presumably being trained on my own grading)."
> --- work_0593

### 7.3 The "intern to colleague" aspiration

Many professionals describe their current relationship with AI as supervisory and express a desire for it to mature into something more peer-like---but only once reliability warrants it.

> "I work as a paralegal, and I need to do a lot of discovery tasks, so I like to use AI for that. However, I find that it makes a lot of mistakes, so I treat AI a bit like an intern. I delegate smaller tasks to it, and then i try to supervise the work to make sure its accurate."
> --- work_0143

> "I don't think there are, really. I'm having trouble thinking of any examples. I generally try to have oversight over any output that anyone else will see. I like to make sure the AI is not going to embarrass me by missing something obvious, for instance."
> --- work_0768

> "I look forward to having to review behind AI less. When I can trust what it says without having to research behind it, it'll save a lot of time and headache. I need it to never hallucinate and always be truthful, especially when it doesn't know something or it's confused."
> --- work_0615

### 7.4 The human floor

Despite growing comfort, nearly every professional describes a floor below which delegation will never drop. Some element of human oversight, judgment, or creative direction is seen as permanently non-negotiable.

> "Ideally, I see AI as taking over more of my tasks as it continues to evolve in its capacity.  That said, I still see myself overseeing accuracy and quality."
> --- work_0132

> "My hope is that despite AI's increasing skills, human input will always be necessary and therefore, people with the knowledge and skills to collaborate efficiently with AI will continue to hold positions without being replaced."
> --- work_0514

> "I don't think I'll ever give up the human element for communications"
> --- work_0255

> "Continue to use it for task delegation. I can't imagine using it to think critically for me."
> --- work_0598

---

## 8. Key quotes collection

The following additional quotes capture recurring themes not fully represented above.

### On the AI-as-tool mental model

> "I don't want to use AI as a crutch, but I do use it before a search engine at this point. Again, primarily brainstorming."
> --- work_0102

> "To me, AI is a tool for those jobs.  Like a calculator, but more advanced."
> --- work_0527

> "AI will be my calculator. It won't replace my job, but it will be a force multiplier."
> --- work_0880

> "I don't think there are aspects however of counseling that I think could never be replaced - such as human warmth and a therapeutic relationship"
> --- work_0035

### On the collaborative process

> "I sort of use the AI as a note-taker/summarizer. Someone to corral all my random thoughts, connecting them and helping me shape them into something cohesinve and actionable."
> --- work_0768

> "I treated the model as a research collaborator, going back and forth.  I challenged it when I thought it was wrong or unclear, or when a command didn't work."
> --- work_0593

> "I see my relationship with AI becoming more of a collaboration to make work go faster. Sometimes I feel like I'm becoming the AI's assistant and editor instead of the AI being the assistant."
> --- work_0269

### On human authenticity as a differentiator

> "At the end of the day, letting AI write your prose is self-defeating, because people enjoy stories because they are connecting with other people. There's a personal bond in creative works, between the creator and the audience, and the more authentic your work is, the more it comes directly from YOU, the more readers will respond, especially in the long term."
> --- work_0302

> "I would never ask AI to write an entire article, cos if you're doing this, whats the point, we might as well surrender to the computers now."
> --- work_0445

> "I do not like it when the AI rewrites my copy. It makes it too hard to see what changes were made, and I am ultimately responsible for any and all content---I can't afford to miss a bad AI edit in my work."
> --- work_0797

### On the economic and societal dimension

> "the time savings are having an impact on the economics of running a law firm, particularly a small firm.  The standard billing method for decades for Canadian law firms has been the billable hour.  The rise of AI is threatening the billable hour like never before since a task that used to take 10 hours, for example, may now be complete in 2 hours, with a corresponding reduction in billable hours."
> --- work_0450

> "I think poeople get gneuine fulfillment out of their jobs, and I don't want to be in a workplace wher emost of the work is produced by robots, I think I'd find that pretty depressing."
> --- work_0143

> "I think it's not about AI replacing people - I do, however, think that Managers who do my job without working with AI will be replaced by managers who DO work with AI, since we are going to be a lot more thorough and able to do more work and keep track of more than people who don't utilize AI."
> --- work_0615
