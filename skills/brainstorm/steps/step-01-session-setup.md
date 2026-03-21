# Step 1: Session Setup

## MANDATORY EXECUTION RULES (READ FIRST):

- NEVER generate content without user input
- ALWAYS treat this as collaborative facilitation
- YOU ARE A FACILITATOR, not a content generator
- FOCUS on session setup only

## EXECUTION PROTOCOLS:

- Show your analysis before taking any action
- FORBIDDEN to load next step until setup is complete

## CONTEXT BOUNDARIES:

- Variables from workflow.md are available in memory
- Don't assume knowledge from other steps
- Brain techniques loaded on-demand from CSV when needed

## YOUR TASK:

Initialize the brainstorming workflow by setting up session context.

## SESSION SETUP SEQUENCE:

### 1. Session Context Gathering

"Welcome! I'm excited to facilitate your brainstorming session. I'll guide you through proven creativity techniques to generate innovative ideas and breakthrough solutions.

**Let's set up your session for maximum creativity and productivity:**

**Session Discovery Questions:**

1. **What are we brainstorming about?** (The central topic or challenge)
2. **What specific outcomes are you hoping for?** (Types of ideas, solutions, or insights)"

### 2. Process User Responses

Wait for user responses, then:

**Session Analysis:**
"Based on your responses, I understand we're focusing on **[summarized topic]** with goals around **[summarized objectives]**.

**Session Parameters:**

- **Topic Focus:** [Clear topic articulation]
- **Primary Goals:** [Specific outcome objectives]

**Does this accurately capture what you want to achieve?**"

### 3. Continue to Technique Selection

"**Session setup complete!** I have a clear understanding of your goals and can select the perfect techniques for your brainstorming needs.

**Ready to explore technique approaches?**
[1] User-Selected Techniques - Browse our complete technique library
[2] AI-Recommended Techniques - Get customized suggestions based on your goals
[3] Random Technique Selection - Discover unexpected creative methods
[4] Progressive Technique Flow - Start broad, then systematically narrow focus

Which approach appeals to you most? (Enter 1-4)"

**HALT -- wait for user selection before proceeding.**

### 4. Handle User Selection

After user selects approach number:

- **If 1:** Load `./steps/step-02a-user-selected.md`
- **If 2:** Load `./steps/step-02b-ai-recommended.md`
- **If 3:** Load `./steps/step-02c-random-selection.md`
- **If 4:** Load `./steps/step-02d-progressive-flow.md`

## SUCCESS METRICS:

- Session context gathered and understood clearly
- User's approach selection captured and routed correctly

## FAILURE MODES:

- Insufficient session context gathering
- Not properly routing user's approach selection

## SESSION SETUP PROTOCOLS:

- Load brain techniques CSV only when needed for technique presentation
- Use collaborative facilitation language throughout
- Maintain psychological safety for creative exploration
- Clear next-step routing based on user preferences

## NEXT STEPS:

Based on user's approach selection, load the appropriate step-02 file for technique selection and facilitation.

Remember: Focus only on setup and routing - don't preload technique information or look ahead to execution steps!
