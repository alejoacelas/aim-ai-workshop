# TODO: Workshop Site Expansion

Ideas for expanding the workshop material. The end goal is being the go-to tutorial for installing Claude Code for any EA or similar demographic.

## Personalized first page

The web page should prompt you on the first page to choose among a small set of options to customize the experience. It should let you choose your OS. It should ask if you have a Claude Code or ChatGPT subscription — and if you select "no, I don't have any of this," it tells you that you should consider getting one and links you to a page outside. Then it asks how much time you have for this. Based on that, we can do hard-coded rules for "okay, if you have this time, we recommend doing this and this and this," based on how long each thing takes.

There might be a separate question, which is: how much detail or context do you want? Like, "I just want to get it installed and get it running as fast as possible" versus "I want more content, more context, want to read more." This is a lot of features and options, but the idea is to use Claude Code to help fill some of those.

## More aggressive step-by-step UI

Right now the page is a standard document, pretty linear. I want to make it so it forces you to pay attention to the right things. If there's a numbered list of steps to follow, the number should be really big, then 3 to 5 words that are really big describing what you should be doing, and then an explanation that's smaller. It should be much more aggressive in forcing you to take the actions the way the writer expects you to take them.

## Adversarial testing agent

We should make an internal agent — like an internal `.md` configuration — to automatically role-play as a user. Just say, "Hey, what are the things that are most likely to go wrong?" Like, the user forgets to reload the terminal and they don't see the command. It should be pretty thorough with all of that.

## Detailed per-user tracking

I want really detailed tracking of time and clicks and everything. Basically, I want information about how much time someone spent on a page at the level of each individual. For each individual user, I want to collect their whole journey through the page — how much time they spent on the first page, at what time they clicked to the next, which links they clicked, all of that — and collect it.

## Terminal-to-web bridge via `helpme` CLI

Maybe this goes well with the `helpme` command. We currently have a `helpme` CLI. Maybe we want the `helpme` CLI installation to be dynamically generated — a custom command per user. And we want to have the CLI ping the same servers as the web page, such that not only do we have the full things that happened on their computers, on their terminal, but — I'm not sure exactly what I want to do here because some people will be using Codex instead of Claude Code. I'll think about it. But assuming only Claude Code for now, the web page can use information that is sent by the terminal command and maybe have some chat in there that they can use. And all of that information is recorded along with the rest of the tracking to allow us to get a report on how this is working.

## Better content authoring format

Currently we have articles written in Markdown and then parsed to present on the web page. But I think we're just kind of reinventing CSS or reinventing Tailwind. What I want is some way in which individual pages can be separate text files — something that's pretty readable, really easy to edit by hand. Maybe the best way is using classes for the most part and just a few commands, such that it's pretty easy to write and read those files, but we still have rich formatting for the page.

---

## Implementation ideas (tentative — investigate these rather than going with them directly)

- **Personalization:** Could be client-side with localStorage or query params. Worth investigating whether conditional rendering in the existing setup is enough or if something more structured is needed.
- **Step UI:** Look into existing stepper/wizard component patterns before building custom.
- **Adversarial agent:** A Claude Code skill that walks through the tutorial and lists failure points could work. Also worth investigating if a Playwright-based automated walkthrough would catch more real issues.
- **Tracking:** Something like Posthog or Plausible, or a lightweight custom event logger on Cloudflare Workers. Investigate what gives per-user journey data without heavy infra.
- **Terminal-web bridge:** Most complex piece. Investigate whether the existing `helpme` Cloudflare Worker could be extended with WebSocket/SSE, or if polling is sufficient.
- **Content format:** Look into MDX, Markdoc, or a custom lightweight markup. Markdoc might be the sweet spot but investigate before picking.
