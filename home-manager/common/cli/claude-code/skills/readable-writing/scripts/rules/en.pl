use strict;
use warnings;
use utf8;

my @LITERAL = (
    {
        p => '語彙', c => 'Throat-clearing openers',
        problem => 'An announcement phrase that delays the point.',
        cut => 1,
        terms => [
            "Here's the thing:",
            "Here's what [X]",
            "Here's this [X]",
            "Here's that [X]",
            "Here's why [X]",
            'The uncomfortable truth is',
            'It turns out',
            'The real [X] is',
            'Let me be clear',
            'The truth is,',
            "I'll say it again:",
            "I'm going to be honest",
            'Can we talk about',
            "Here's what I find interesting",
            "Here's the problem though",
        ],
    },
    {
        p => '語彙', c => 'Emphasis crutches',
        problem => 'Adds no meaning.',
        cut => 1,
        terms => [
            'Full stop.',
            'Period.',
            'Let that sink in.',
            'This matters because',
            'Make no mistake',
        ],
    },
    {
        p => '語彙', c => 'Business jargon',
        problem => 'Replace with plain language.',
        cut => 0,
        terms => [
            'Navigate',
            'Unpack',
            'Lean into',
            'Landscape',
            'Game-changer',
            'Double down',
            'Deep dive',
            'Take a step back',
            'Moving forward',
            'Circle back',
            'On the same page',
        ],
    },
    {
        p => '語彙', c => 'Adverbs',
        problem => 'An adverb standing in for a measurement.',
        cut => 1,
        terms => [
            'really',
            'just',
            'literally',
            'genuinely',
            'honestly',
            'simply',
            'actually',
            'deeply',
            'truly',
            'fundamentally',
            'inherently',
            'inevitably',
            'interestingly',
            'importantly',
            'crucially',
        ],
    },
    {
        p => '語彙', c => 'Filler phrases',
        problem => 'Fills space without adding content.',
        cut => 1,
        terms => [
            'At its core',
            "In today's [X]",
            "It's worth noting",
            'At the end of the day',
            'When it comes to',
            'In a world where',
            'The reality is',
        ],
    },
    {
        p => '語彙', c => 'Lazy extremes',
        problem => 'A sweeping word standing in for the specific range.',
        cut => 0,
        terms => [
            'every',
            'always',
            'never',
            'everyone',
            'everybody',
            'nobody',
        ],
    },
    {
        p => '語彙', c => 'Performative emphasis',
        problem => 'Manufactured intimacy.',
        cut => 1,
        terms => [
            'I promise',
        ],
    },
    {
        p => '語彙', c => 'Meta-commentary',
        problem => 'An aside about the writing itself.',
        cut => 1,
        terms => [
            'Hint:',
            'Plot twist:',
            'Spoiler:',
            'You already know this, but',
            "But that's another post",
        ],
    },
    {
        p => '語彙', c => 'Set phrases',
        problem => 'A stock construction that shows up regardless of the subject.',
        cut => 0,
        terms => [
            'creeps in',
            'is a feature, not a bug',
            'Dressed up as',
        ],
    },
);

# `[A-Za-z]{3,}ly` に引っかかるが副詞ではない語。
my %LY_STOP = map { $_ => 1 } qw(
    only
    family
    reply
    apply
    supply
    assembly
    anomaly
    italy
    july
    ally
    rely
    multiply
    imply
    comply
    holy
    ugly
    silly
    jolly
    folly
    belly
    jelly
    rally
    monopoly
    panoply
    fly
    ply
    bully
    gully
    tally
    dolly
    wholly
    melancholy
    poly
    duly
    unruly
    homily
    doily
);

return {
    literal => \@LITERAL,
    ly_stop => \%LY_STOP,
};
