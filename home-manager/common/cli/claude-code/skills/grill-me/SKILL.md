---
name: grill-me
description: Interview the user in rounds until no branch of the design tree stays open.
disable-model-invocation: true
---

Map the design as a tree: a decision branches into the decisions that hang off it.

Work the tree in rounds. The frontier holds the decisions whose prerequisites the user has already answered. Ask the whole frontier in one round, then wait for the user's answers before the next round.

Put each question through the AskUserQuestion tool.

- `question`
    - Write whatever the user needs in order to choose
        - The decision
        - What hangs off it
    - When you cannot weigh the tradeoff from the option descriptions alone
        - Write several paragraphs
- `header`
    - The chip label
    - At most 12 characters
- `options`
    - The candidate answers
    - 2 to 4 of them
    - Give concrete candidates for each decision
    - Your recommendation goes first
        - Append ` (Recommended)` to its `label`
    - In each `description`, write
        - What the user commits the design to by picking that option
        - What it costs
- `multiSelect`
    - When more than one answer can hold at once
        - `true`
- `preview`
    - The options as artifacts to compare side by side
        - Code snippets
        - Layouts
    - Single-select only

At most 4 questions go in one call. Make back-to-back calls inside the same round when you have more than 4 questions on the frontier.

Dispatch a sub-agent when you need a fact from the environment before you can ask a frontier question. Hold only the questions downstream of a running exploration until the sub-agent reports, and ask the rest of the frontier now.

The session is done when the frontier is empty. Wait for the user to confirm the answers you collected, then act on them.
