# Document structure

## What to find

### Headings where you make a claim

- Why We Chose X
    - Reasons for picking X
- What X Taught Us About Y
    - Findings from the X outage
- X Dies the Moment You Lose Y
    - Impact of removing Y
- Three Principles From the Trenches
    - Rules we follow now
- How X Solves Y
    - X and Y

### Announcing the structure

- Delete
    - The rest of this essay explains...
    - Let me walk you through...
    - In this section, we'll...
    - As we'll see...
    - I want to explore...

### Writing what you won't do

- Delete
    - Non-goals: anything the marketing team owns
    - We chose not to use a NAT gateway
- Rewrite as what you do
    - We don't send the token in the query string
        - The client sends the token in the `Authorization` header
- Keep
    - CloudTrail has no record of `DisassociateAddress`
    - You can't find out from the API whether an ENI is live

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

### The head of a design document

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
