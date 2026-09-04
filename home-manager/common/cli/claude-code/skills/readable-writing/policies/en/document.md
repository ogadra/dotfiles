# Document structure

## Forms to find

### Headings where you make a claim

| Avoid | Use instead |
|---|---|
| Why We Chose X | Reasons for picking X |
| What X Taught Us About Y | What we found in the X outage |
| X Dies the Moment You Lose Y | Impact of removing Y |
| Three Principles From the Trenches | Rules we follow now |
| How X Solves Y | X and Y |

### Announcing the structure

| Avoid | Fix |
|---|---|
| The rest of this essay explains... | Delete |
| Let me walk you through... | Delete |
| In this section, we'll... | Delete |
| As we'll see... | Delete |
| I want to explore... | Delete |

### Writing what you won't do

| Avoid | Fix |
|---|---|
| Non-goals: anything the marketing team owns | Delete |
| We chose not to use a NAT gateway | Delete |
| We don't send the token in the query string | The client sends the token in the `Authorization` header |
| CloudTrail has no record of `DisassociateAddress` | Keep |
| You can't find out from the API whether an ENI is live | Keep |

#### Before

```
## In scope

- Technical docs
- READMEs

## Non-goals

- Trip reports
- Opinion pieces
- Anything the marketing team owns
```

#### After

```
## In scope

- Technical docs
- READMEs
```

### Bold headings and out-of-scope at the head of a design document

#### Before

```
# Search platform rework

**Goal**: Move Elasticsearch from 7.x to 8.x and swap the Japanese
tokenizer from Kuromoji to Sudachi.

**Out of scope**:
- Search UI changes
- Ranking logic changes
- Moving infrastructure to IaC
```

#### After

```
# Search platform rework

## Goal

Stop losing compound words in search. A query for "machine learning" splits into "machine" and "learning", so unrelated documents rank first.

## Approach

- Move Elasticsearch from 7.x to 8.x
- Swap the Japanese tokenizer from Kuromoji to Sudachi
```

- Turn the bold labels into headings
- Delete the out-of-scope section
- Write what hurts under "Goal"
- Move the means into its own section

