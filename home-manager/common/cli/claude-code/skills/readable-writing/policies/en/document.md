# Document structure

Patterns and fixes live in `common/document.md`. This file holds the English forms and examples.

## Headings that make a claim

| Avoid | Use instead |
|---|---|
| Why We Chose X | Reasons for picking X |
| What X Taught Us About Y | What the X outage showed |
| X Dies the Moment You Lose Y | Impact of removing Y |
| Three Principles From the Trenches | What we changed after running it |
| How X Solves Y | X and Y |

## Announcing the structure

| Avoid | Fix |
|---|---|
| The rest of this essay explains... | Delete |
| Let me walk you through... | Delete |
| In this section, we'll... | Delete |
| As we'll see... | Delete |
| I want to explore... | Delete |

## Listing what's out of scope

Search for `Out of scope`, `Non-goals`, `This document does not cover`.

## Bold headings and out-of-scope together

The head of a design document.

### Before

```
# Search platform rework

**Goal**: Move Elasticsearch from 7.x to 8.x and swap the Japanese
tokenizer from Kuromoji to Sudachi.

**Out of scope**:
- Search UI changes
- Ranking logic changes
- Moving infrastructure to IaC
```

### After

```
# Search platform rework

## Goal

Stop losing compound words in search. A query for "machine learning" splits into "machine" and "learning", so unrelated documents rank first.

## Approach

- Move Elasticsearch from 7.x to 8.x
- Swap the Japanese tokenizer from Kuromoji to Sudachi
```

Turn the bold labels into headings, delete the out-of-scope section, write what hurts under "Goal", and move the means into its own section.

Line breaks mid-sentence are also in `common/symbols.md`.
