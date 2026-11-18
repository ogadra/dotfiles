# Agency

English phrasings for who did what.

## What to find

### False agency

- `a complaint becomes a fix`
    - `The team fixed it that week`
- `a bet lives or dies in days`
    - `Someone kills the project or ships it`
- `the decision emerges`
    - `Someone decides`
- `the culture shifts`
    - `Your teammates change what they do`
- `the conversation moves toward`
    - `Someone steers it`
- `the data tells us`
    - `Someone reads it and draws a conclusion`
- `the market rewards`
    - `Buyers pay for things`
- `the architecture guides`
    - `The designer decided that`

### Passive voice

- `X was created`
    - `Alice created X`
- `It is believed that`
    - `The SRE team believes that`
- `Mistakes were made`
    - `I made two mistakes`
- `The decision was reached`
    - `The tech lead decided`

### Narrator from a distance

- `Nobody designed this.`
    - `Someone took the shortcut under a deadline, and it stayed`
- `This happens because...`
    - `The cache key left out the lockfile hash, so every build missed`
- `This is why...`
    - `I traced it to the retry loop doubling the load`

### Missing first person

- `People tend to...`
    - `I do this too`
- `Teams often...`
    - `On my team, we...`
- `Many engineers struggle with X`
    - `I've been stuck on X for months`
- `Feedback prioritization matters in product work`
    - `Three people complained about the same button last year`

## How to find them

1. Read each sentence subject
    - Collect the ones where an inanimate noun takes an active verb
2. Search for these
    - Search terms
        - `was`
        - `were`
        - `is being`
    - Keep the ones followed by a past participle
    - Check whether the actor appears in the text
3. Collect generalized subjects
    - Search terms
        - `people`
        - `everyone`
        - `teams`
        - `many engineers`
        - `developers`
        - `matters in`
        - `is important`
    - Replace the sentence with something the writer did on a named day
4. Find the sentences that explain why something happened
    - Search terms
        - `nobody`
        - `this happens because`
        - `this is why`
    - Check whether the writer names the mechanism they saw
