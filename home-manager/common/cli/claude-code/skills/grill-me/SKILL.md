---
name: grill-me
description: An interview that runs in rounds until the design tree has no open branches.
disable-model-invocation: true
---

Interview the user until you reach a shared understanding. Map this as a design tree: a decision branches into the decisions that hang off it.

Work the tree in rounds. The frontier holds the decisions whose prerequisites the user has already answered. Ask the whole frontier in one round, then wait for the user's answers before the next round.

Put each question through the AskUserQuestion tool.

- `question`
    - Carries whatever the user needs in order to choose
        - The decision
        - What hangs off it
    - Write several paragraphs
        - Where the tradeoff needs more than the option descriptions
- `header`
    - The chip label
    - At most 12 characters
- `options`
    - The candidate answers
    - 2 to 4 of them
    - Your recommendation goes first
        - Append ` (Recommended)` to its `label`
    - Each `description` says
        - What picking that option commits the design to
        - What it costs
- `Other`
    - The tool appends this escape on its own
    - Give concrete candidates
        - Even where the decision has no obvious menu
- `multiSelect`
    - `true`
        - Where more than one answer can hold at once
- `preview`
    - Where the options are artifacts worth comparing side by side
        - Code snippets
        - Layouts
        - Config
    - Single-select only

One call carries at most 4 questions. A frontier wider than that means back-to-back calls inside the same round.

Once the user answers, recompute the frontier and ask again. Hold any question whose answer depends on another that is still open.

Finding _facts_ is your job. When a frontier question needs a fact from the environment, dispatch a sub-agent to find it. A running exploration is an unsettled prerequisite: hold only the questions downstream of it until the sub-agent reports, and ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: you have visited each branch of the design tree and asked about what you would otherwise have assumed. Wait for the user to confirm you have reached a shared understanding, then act on it.
