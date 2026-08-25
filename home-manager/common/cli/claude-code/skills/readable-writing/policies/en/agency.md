# Agency

Patterns and fixes live in `common/agency.md`. This file holds the English phrasings.

## False agency

Inanimate things taking human verbs. Complaints don't become fixes. Decisions don't emerge. Someone reads the complaint, files the ticket, and merges the patch.

| Avoid | Use instead |
|---|---|
| a complaint becomes a fix | The team fixed it that week |
| a bet lives or dies in days | Someone kills the project or ships it |
| the decision emerges | Someone decides |
| the culture shifts | People change behavior |
| the conversation moves toward | Someone steers it |
| the data tells us | Someone reads it and draws a conclusion |
| the market rewards | Buyers pay for things |
| the architecture guides | The designer decided that |

## Passive voice

| Avoid | Use instead |
|---|---|
| X was created | Name who created it |
| It is believed that | Name who believes it |
| Mistakes were made | Name who made them |
| The decision was reached | Name who decided |

## Narrator from a distance

Floating above the scene instead of putting the reader in it.

| Avoid | Use instead |
|---|---|
| Nobody designed this. | You don't sit down one day and decide to... |
| This happens because... | Name the mechanism you saw |
| This is why... | Name the mechanism you saw |
| People tend to... | You do this too |
| Teams often... | On my team, we... |

## Missing first person

| Avoid | Use instead |
|---|---|
| Many engineers struggle with X | I've been stuck on X for months |
| Feedback prioritization matters in product work | Three people complained about the same button last year |

## How to find them

1. Read every sentence subject. Collect the ones where an inanimate noun takes an active verb.
2. Search for `was`, `were`, `is being` followed by a past participle. Check whether the actor appears in the text.
3. Search for `people`, `everyone`, `nobody`, `teams`, `we`. Check whether each can name someone specific.
4. Search for `many engineers`, `developers`, `matters in`, `is important`. Check whether the sentence can be replaced with something the writer did on a named day.
