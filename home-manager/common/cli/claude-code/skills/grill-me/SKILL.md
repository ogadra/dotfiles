---
name: grill-me
description: A relentless interview to sharpen a plan or design.
disable-model-invocation: true
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round, then wait for the user's answers before the next round.

Put every question through the **AskUserQuestion** tool, never through prose. The tool renders each question and each option in the UI, so that is where the detail belongs:

- `question` carries the whole body: the decision, what hangs off it, whatever the user needs in order to choose. Several paragraphs if the decision earns them.
- `header` is the chip label, at most 12 characters.
- `options` are the candidate answers, 2 to 4 of them. Your recommendation goes first, with ` (Recommended)` appended to its `label`. Each `description` says what picking that option commits the design to, and what it costs.
- The tool appends its own "Other" escape, so never write one yourself. A decision with no obvious menu still gets concrete candidates rather than an open-ended prompt.
- `multiSelect: true` where the answers stack instead of excluding each other.
- `preview` where the options are artifacts worth comparing side by side: code snippets, layouts, config. Single-select only.

One call carries at most 4 questions. A frontier wider than that means back-to-back calls inside the same round, not a narrower round.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
