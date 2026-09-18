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

Name the specific thing — the seven call sites, the missing index, whatever it is. If you can't name it, cut the sentence.

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

- Each has its own strengths
    - We use X
    - We dropped Y
- It's a matter of preference
    - We picked X for this codebase

### Weak negatives

- `it's generally discouraged`
- `you may want to avoid`
- `this is not ideal`
- `consider avoiding`

Say `Don't do X`, and name the breaking point when you know it.

- Maintenance cost may grow
    - This breaks once the team passes ten people

### Extremes with no middle

- `dramatically faster`
- `a game-changer`
- `10x`
- `never do this`
- `by far the best`

Write what you measured.

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

### Hearsay you could have checked

- `apparently`
- `seems to have`
- `reportedly`
- `as I understand it`
- `from what I can tell`
- `presumably`
- `I believe`

#### Before

```
KDE apparently dropped `org_kde_kwin_blur` in KWin 6.7. wezterm reportedly does not speak its replacement yet.
```

#### After

```
KDE dropped `org_kde_kwin_blur` in KWin 6.7 and added `ext_background_effect_manager_v1`. wezterm picked up the new protocol in PR #7615.
```

### Stacked hedges

- `might`
- `could potentially`
- `in some cases`
- `arguably`

A hedge is a word that narrows what you take on. Two or more in one sentence is the finding.

Write the scope you're claiming.

- This is only my experience
    - On my ten-person team

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
