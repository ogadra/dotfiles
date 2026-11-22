# Agency

## Patterns

### False agency

| Before | After |
|---|---|
| `a complaint becomes a fix` | `The team fixed it that week` |
| `a bet lives or dies in days` | `The lead kills the project or ships it` |
| `the decision emerges` | `Your manager decides` |
| `the culture shifts` | `Your teammates change what they do` |
| `the conversation moves toward` | `Whoever runs the meeting steers it` |
| `the data tells us` | `An analyst reads it and draws a conclusion` |
| `the market rewards` | `Our three biggest customers paid for the export feature` |
| `the architecture guides` | `The designer decided that` |

### Passive voice

| Before | After |
|---|---|
| `X was created` | `Alice created X` |
| `It is believed that` | `The SRE team believes that` |
| `Mistakes were made` | `I made two mistakes` |
| `The decision was reached` | `The tech lead decided` |

### Narrator from a distance

| Before | After |
|---|---|
| `Nobody designed this.` | `A teammate took the shortcut under a deadline, and it stayed` |
| `This happens because...` | `I left the lockfile hash out of the cache key, so every build missed` |
| `This is why...` | `I traced it to the retry loop doubling the load` |

### Missing first person

| Before | After |
|---|---|
| `People tend to...` | `I do this too` |
| `Teams often...` | `On my team, we...` |
| `Many engineers struggle with X` | `I've been stuck on X for months` |
| `Feedback prioritization matters in product work` | `Last year three of my users complained to me about the same button` |

## How to find them

1. Read each sentence subject
    - Collect the ones where an inanimate noun takes an active verb
2. Collect passive sentences
    - Search for these
        - `was`
        - `were`
        - `is being`
    - Keep the ones followed by a past participle
    - Check whether the actor appears in the text
3. Collect generalized statements
    - Search for these
        - `people`
        - `everyone`
        - `teams`
        - `many engineers`
        - `developers`
        - `matters in`
        - `is important`
    - Keep the ones with no named person
    - Also keep the ones with no date
4. Find the sentences that explain why something happened
    - Search for these
        - `nobody`
        - `this happens because`
        - `this is why`
    - Check whether the writer names the mechanism they saw
