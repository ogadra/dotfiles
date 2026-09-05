# Stance

## What to find

### Claims you can't argue with

- `The reasons are structural`
- `The implications are significant`
- `This is the deepest problem`
- `The stakes are high`
- `The consequences are real`
- `This is genuinely hard`
- `This is what [X] actually looks like`
- `actually matters`

#### Before

```
This refactor has a structural problem. The implications are significant and the stakes are high.
```

#### After

```
This refactor left seven places where `OrderService` calls `PaymentGateway` directly. Swapping the payment provider means editing all seven.
```

Name the specific thing. If you can't, cut the sentence.

### Dodging the conclusion

- `it depends`
- `there are tradeoffs`
- `your mileage may vary`
- `reasonable people disagree`
- `both approaches have merit`

#### Before

```
Whether to use a monorepo depends. There are tradeoffs, and reasonable people disagree.
```

#### After

```
We went with a monorepo. We only have three packages, and keeping their versions in step cost more than splitting them was worth.
```

### Praising everything

| Avoid | Use instead |
|---|---|
| Each has its own strengths | We use X. We dropped Y |
| It's a matter of preference | We picked X |
| There's no single right answer | We picked X for this codebase |

### Weak negatives

- `it's generally discouraged`
- `you may want to avoid`
- `this is not ideal`
- `consider avoiding`

Say `Don't do X`. If you know the breaking point, name it.

| Avoid | Use instead |
|---|---|
| Maintenance cost may grow, so take care | This breaks once the team passes ten people |

### Extremes with no middle

- `dramatically faster`
- `a game-changer`
- `10x`
- `never do this`
- `by far the best`

Write what you measured:

- `12 minutes down to 3`
- `within noise`
- `it flipped under load`

#### Before

```
Adding the index made the query dramatically faster. It was a game-changer.
```

#### After

```
Adding the index took this query from 1.2s to 40ms. The other queries didn't move.
```

### Strong claims with no evidence

- `a powerful approach`
- `an elegant solution`
- `incredibly useful`
- `the right way to do this`

#### Before

```
This is a powerful approach and an elegant solution. It's incredibly useful.
```

#### After

```
This took our median review wait from two days to half a day, measured over 120 PRs across three months.
```

### Stacked hedges

- `might`
- `could potentially`
- `in some cases`
- `arguably`

A hedge is a word that narrows what you take on. Count those. Attribution words mark where a fact came from.

- `I read that`
- `the biography says`

Write the scope you're claiming.

| Avoid | Use instead |
|---|---|
| This is only my experience and results may vary by org size | On my ten-person team |

### Ritual disclaimers

- `And that's okay.`
- `Not always. Not perfectly.`
- `Your situation may differ.`
- `This is just my experience.`

#### Before

```
## Caching

The first build went from nine minutes to three. Your situation may differ.

## Retries

We retry up to three times. This is just my experience.
```

#### After

```
## Caching

The first build went from nine minutes to three.

## Retries

We retry up to three times. I picked that from a workload of a hundred thousand jobs a day.
```
