# Vocabulary

English words and set phrases you can find by searching.

## What to find

### Throat-clearing openers

Announcement phrases that delay the point. Cut them and state the content.

- `Here's the thing:`
- `Here's what [X]`
- `Here's this [X]`
- `Here's that [X]`
- `Here's why [X]`
- `The uncomfortable truth is`
- `It turns out`
- `The real [X] is`
- `Let me be clear`
- `The truth is,`
- `I'll say it again:`
- `I'm going to be honest`
- `Can we talk about`
- `Here's what I find interesting`
- `Here's the problem though`

Any `here's what`, `here's this`, or `here's that` construction is a run-up to the point. Cut it and write the point.

#### Before

```
Here's the thing: building products is hard. Not because the technology is complex. Because people are complex. Let that sink in.
```

#### After

```
Building products is hard. Technology is manageable. People are the constraint.
```

### Emphasis crutches

These add no meaning. Delete them.

- `Full stop.`
- `Period.`
- `Let that sink in.`
- `This matters because`
- `Make no mistake`
- `Here's why that matters`

#### Before

```
The build takes nine minutes. Full stop. This matters because your team runs it six times a day. Let that sink in.
```

#### After

```
The build takes nine minutes and the team runs it six times a day.
```

### Business jargon

Replace with plain language.

| Avoid | Use instead |
|---|---|
| Navigate (challenges) | Handle, address |
| Unpack (analysis) | Explain, examine |
| Lean into | Accept, embrace |
| Landscape (context) | Situation, field |
| Game-changer | Significant, important |
| Double down | Commit, increase |
| Deep dive | Analysis, examination |
| Take a step back | Reconsider |
| Moving forward | Next, from now |
| Circle back | Return to, revisit |
| On the same page | Aligned, agreed |

#### Before

```
In today's fast-paced landscape, we need to lean into discomfort and navigate uncertainty with clarity. This matters because your competition isn't waiting.
```

#### After

```
Move faster. Your competition already has.
```

### Adverbs

Kill all adverbs. No -ly words, no softeners, no intensifiers, no hedges.

- `really`
- `just`
- `literally`
- `genuinely`
- `honestly`
- `simply`
- `actually`
- `deeply`
- `truly`
- `fundamentally`
- `inherently`
- `inevitably`
- `interestingly`
- `importantly`
- `crucially`

#### Before

```
This is really just a simple change that genuinely improves things quite significantly.
```

#### After

```
This change takes the build from nine minutes to three.
```

### Filler phrases

- `At its core`
- `In today's [X]`
- `It's worth noting`
- `At the end of the day`
- `When it comes to`
- `In a world where`
- `The reality is`

#### Before

```
At its core, in today's engineering landscape, it's worth noting that build speed matters. At the end of the day, the reality is that slow feedback hurts.
```

#### After

```
A nine-minute build run six times a day costs each engineer fifty-four minutes.
```

### Lazy extremes

Sweeping words standing in for authority. Replace with the specific range.

- `every`
- `always`
- `never`
- `everyone`
- `everybody`
- `nobody`

#### Before

```
Everyone hits this problem. It always happens, and nobody catches it in review.
```

#### After

```
Three of the five services in this repo hit it. It shows up once the payload passes 1MB, and no reviewer has caught it so far.
```

### Performative emphasis

Manufactured intimacy and sincerity.

- `I promise`
- `They exist, I promise`

#### Before

```
There are teams that ship on Fridays. They exist, I promise.
```

#### After

```
Two teams here ship on Fridays: Payments and Search.
```

### Meta-commentary

Asides about the writing itself.

- `Hint:`
- `Plot twist:`
- `Spoiler:`
- `You already know this, but`
- `But that's another post`

#### Before

```
Plot twist: the cache key was wrong. You already know this, but keys need the lockfile hash. But that's another post.
```

#### After

```
The cache key was wrong. It needs the lockfile hash in it.
```

### Set phrases

Stock constructions that show up regardless of the subject.

- `creeps in`
- `X is a feature, not a bug`
- `Dressed up as`

#### Before

```
Latency creeps in once the queue backs up. The retry storm is a feature, not a bug, dressed up as resilience.
```

#### After

```
Latency rises once the queue passes about 5,000 messages. The retries make it worse: each failure adds three more requests.
```

## How to find them

1. Search for every phrase above
    - One hit is enough to report
2. Search for words ending in -ly
