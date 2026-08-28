use strict;
use warnings;
use utf8;
use open qw(:std :utf8);

my ($lang_dirs, $target) = @ARGV;
die "usage: mechanical.pl <lang-dirs> <target-file>\n" unless defined $target;

my %lang = map { $_ => 1 } split ' ', $lang_dirs;

open my $fh, '<', $target or die "mechanical.pl: cannot read $target: $!\n";
my @lines = map { chomp; $_ } <$fh>;
close $fh;

my @skip;
my $in_code = 0;
my ($fence_char, $fence_len) = ('`', 3);
my $in_front = (@lines && $lines[0] eq '---') ? 1 : 0;
for my $i (0 .. $#lines) {
    my $line = $lines[$i];
    if ($in_front) {
        $skip[$i] = 1;
        $in_front = 0 if $i > 0 && $line eq '---';
        next;
    }
    if ($in_code) {
        $skip[$i] = 1;
        $in_code = 0 if $line =~ /^\s*[$fence_char]{$fence_len,}\s*$/;
        next;
    }
    if ($line =~ /^\s*(`{3,}|~{3,})/) {
        ($fence_char, $fence_len) = (substr($1, 0, 1), length $1);
        $in_code = 1;
        $skip[$i] = 1;
        next;
    }
    $skip[$i] = $in_code || $line =~ /^\s{4,}\S/ && $line !~ /^\s*(?:[-*+]|\d+\.)\s/;
}

sub masked {
    my $line = shift;
    $line =~ s/`[^`]*`/'~' x 3/ge;
    $line =~ s{https?://\S+}{'~' x 3}ge;
    return $line;
}

sub is_structural {
    my $line = shift;
    return 1 if $line =~ /^\s*$/;
    return 1 if $line =~ /^\s*#/;
    return 1 if $line =~ /^\s*(?:```|~~~)/;
    return 1 if $line =~ /^\s*\|/;
    return 1 if $line =~ /^\s*(?:[-*_]\s*){3,}$/;
    return 1 if $line =~ /^\s*(?:[-*+]|\d+\.)\s/;
    return 1 if $line =~ /^\s*>/;
    return 0;
}

my @findings;
sub add {
    my ($perspective, $line, $quote, $category, $problem, $fix) = @_;
    push @findings, {
        perspective => $perspective,
        line        => $line,
        quote       => $quote,
        category    => $category,
        problem     => $problem,
        fix         => $fix,
    };
}

sub term_re {
    my ($term, $l) = @_;
    my @parts = split /〜|○○|\[X\]/, $term, -1;
    my $pat = join('.{0,25}', map { quotemeta } @parts);
    if ($l eq 'en') {
        $pat = '\b' . $pat if $term =~ /^\w/;
        $pat = $pat . '\b' if $term =~ /\w$/;
        return qr/$pat/i;
    }
    return qr/$pat/;
}

my @LITERAL = (
    {
        l => 'ja', p => '語彙', c => '表層の定型句',
        problem => '記事の導入と締めに置かれる決まり文句。',
        cut => 0,
        terms => ['いかがでしたでしょうか', 'いかがでしたか', 'ぜひ参考にしてください',
            'ぜひ〜してみてください', '○○の重要性を再認識しました', '近年〜が注目されています',
            '現代社会において〜は重要なテーマです'],
    },
    {
        l => 'ja', p => '語彙', c => '咳払いの前置き',
        problem => '本題に入る前の時間稼ぎ。',
        cut => 1,
        terms => ['実はですね、', '結論から言うと', '正直に言うと', '率直に言いますが',
            'ここで重要なのは', 'ひとつ言っておきたいのは', '結局のところ', '本当のところ', 'あえて言うなら'],
    },
    {
        l => 'ja', p => '語彙', c => '曖昧な指示語',
        problem => '何を指しているかを書かずに前の記述を指している。',
        cut => 0,
        terms => ['も同じ', '同様に', '同じく', '上記の通り', '前述の'],
    },
    {
        l => 'ja', p => '語彙', c => '横文字メタファー',
        problem => 'IT用語を本来の対象以外に比喩で持ち込んでいる。',
        cut => 0,
        terms => ['思考のOSをアップデート', '人生をハック', '習慣をインストール',
            'マインドをリファクタリング', '頭の中にラボ', 'キャリアをポートフォリオ', '学びをアセット'],
    },
    {
        l => 'ja', p => '語彙', c => 'ビジネスジャーゴン',
        problem => '普通の言葉に置き換えられる。',
        cut => 0,
        terms => ['にコミットする', 'にレバレッジ', 'の解像度を上げる', 'にディープダイブ',
            'をアラインする', 'のスケールを取りに行く', 'ROIを最大化', 'にピボットする'],
    },
    {
        l => 'ja', p => '語彙', c => '過剰なカタカナ表記',
        problem => '普通の日本語に戻せるカタカナ語。',
        cut => 0,
        terms => ['コンテキスト', 'アライメント', 'コミュニケーション', 'インテグリティ',
            'コラボレーション', 'インプリメンテーション', 'プライオリティ', 'アグリー', 'ナレッジ'],
    },
    {
        l => 'ja', p => '主体', c => 'アカデミック自称',
        problem => '地の文で使うと翻訳論文の口調になる。',
        cut => 0,
        terms => ['本稿', '本記事', '本論考', '筆者'],
    },
    {
        l => 'en', p => '語彙', c => 'Throat-clearing openers',
        problem => 'An announcement phrase that delays the point.',
        cut => 1,
        terms => ["Here's the thing:", "Here's what [X]", "Here's this [X]", "Here's that [X]",
            "Here's why [X]", 'The uncomfortable truth is', 'It turns out', 'The real [X] is',
            'Let me be clear', 'The truth is,', "I'll say it again:", "I'm going to be honest",
            'Can we talk about', "Here's what I find interesting", "Here's the problem though"],
    },
    {
        l => 'en', p => '語彙', c => 'Emphasis crutches',
        problem => 'Adds no meaning.',
        cut => 1,
        terms => ['Full stop.', 'Period.', 'Let that sink in.', 'This matters because', 'Make no mistake'],
    },
    {
        l => 'en', p => '語彙', c => 'Business jargon',
        problem => 'Replace with plain language.',
        cut => 0,
        terms => ['Navigate', 'Unpack', 'Lean into', 'Landscape', 'Game-changer', 'Double down',
            'Deep dive', 'Take a step back', 'Moving forward', 'Circle back', 'On the same page'],
    },
    {
        l => 'en', p => '語彙', c => 'Adverbs',
        problem => 'An adverb standing in for a measurement.',
        cut => 1,
        terms => ['really', 'just', 'literally', 'genuinely', 'honestly', 'simply', 'actually',
            'deeply', 'truly', 'fundamentally', 'inherently', 'inevitably', 'interestingly',
            'importantly', 'crucially'],
    },
    {
        l => 'en', p => '語彙', c => 'Filler phrases',
        problem => 'Fills space without adding content.',
        cut => 1,
        terms => ['At its core', "In today's [X]", "It's worth noting", 'At the end of the day',
            'When it comes to', 'In a world where', 'The reality is'],
    },
    {
        l => 'en', p => '語彙', c => 'Lazy extremes',
        problem => 'A sweeping word standing in for the specific range.',
        cut => 0,
        terms => ['every', 'always', 'never', 'everyone', 'everybody', 'nobody'],
    },
    {
        l => 'en', p => '語彙', c => 'Performative emphasis',
        problem => 'Manufactured intimacy.',
        cut => 1,
        terms => ['I promise'],
    },
    {
        l => 'en', p => '語彙', c => 'Meta-commentary',
        problem => 'An aside about the writing itself.',
        cut => 1,
        terms => ['Hint:', 'Plot twist:', 'Spoiler:', 'You already know this, but', "But that's another post"],
    },
    {
        l => 'en', p => '語彙', c => 'Set phrases',
        problem => 'A stock construction that shows up regardless of the subject.',
        cut => 0,
        terms => ['creeps in', 'is a feature, not a bug', 'Dressed up as'],
    },
);

my @FAMILY = (
    {
        l => 'ja', p => '語彙', c => 'AI偏愛語',
        families => {
            '質感を装う語' => ['泥臭い', '泥臭さ', '手触り', '肌感', '肌感覚', '体温', '温度感', '熱量', '血の通った'],
            '認知を装う語' => ['解像度', '腹落ち', 'メンタルモデル', '文脈'],
            '評価を装う語' => ['本質', '本質的', '地に足のついた', '等身大', '効く', '効いた', '効いている', '効果的'],
            '抽象比喩'     => ['営み', '装置', '設計', 'インフラ', '接続'],
            '思想語'       => ['思想', '原則', '哲学'],
        },
    },
    {
        l => 'ja', p => '語彙', c => '必殺技造語',
        families => {
            '真理系'   => ['真理', '真実'],
            '到達点系' => ['結末', '結実', '宿命', '運命', '境地', '極致', '究極'],
            '虚系'     => ['虚飾', '装飾', '虚像'],
            '良いとされているもの系' => ['美学', '徳', '品性'],
            '奥深い系' => ['重厚感', '深淵', '禁欲的'],
            '感情系'   => ['優美', '繊細'],
            '理性系'   => ['残酷', '冷徹', '冷酷', '過酷'],
            '圧縮系'   => ['凝縮', '結晶'],
        },
    },
    {
        l => 'ja', p => '語彙', c => '比喩のテンプレ語', mode => 'total',
        families => {
            '道案内系' => ['地図', '羅針盤', 'コンパス'],
            '手順書系' => ['仕様書', '設計書', 'レシピ'],
            '構造系'   => ['土台', '柱', '骨格'],
            '動力系'   => ['エンジン', '潤滑油'],
            '添加系'   => ['栄養', 'スパイス'],
            '変化を起こす系' => ['触媒', '起爆剤'],
            '本質系'   => ['DNA'],
            '不可分系' => ['車の両輪'],
        },
    },
);

my @JA_ADVERBS = ('非常に', 'とても', 'かなり', '本当に', '実に', '確かに');

my %LY_STOP = map { $_ => 1 } qw(
    only family reply apply supply assembly anomaly italy july ally rely
    multiply imply comply holy ugly silly jolly folly belly jelly rally
    monopoly panoply fly ply bully gully tally dolly wholly melancholy
    poly duly unruly homily doily
);

for my $rule (@LITERAL) {
    next unless $rule->{c} eq 'Adverbs';
    $LY_STOP{ lc $_ } = 1 for @{ $rule->{terms} };
}

my $spaced = qr/(?<=[\p{Hiragana}\p{Katakana}\p{Han}]) (?=[\p{Hiragana}\p{Katakana}\p{Han}A-Za-z0-9])|(?<=[A-Za-z0-9]) (?=[\p{Hiragana}\p{Katakana}\p{Han}])/;
my $terminator = qr/[。．.！？!?：:；;」』）】\)\]"']$/;
my $emoji = qr/[\x{1F000}-\x{1FAFF}\x{2600}-\x{26FF}\x{2705}\x{2728}\x{274C}\x{FE0F}]/;

for my $i (0 .. $#lines - 1) {
    next if $skip[$i] || $skip[$i + 1];
    my ($cur, $next) = ($lines[$i], $lines[$i + 1]);
    next if is_structural($cur) || is_structural($next);
    next if $cur =~ $terminator;
    add('記号', ($i + 1) . '-' . ($i + 2), "$cur\n$next", '文中での改行',
        '文の途中で改行が入っていて、1文が2行に割れている。', "$cur $next");
}

for my $i (0 .. $#lines) {
    next if $skip[$i];
    my $line = $lines[$i];
    my $body = masked($line);
    my $no = $i + 1;

    my $bold_only = $body =~ /^\s*\*\*[^*]+\*\*\s*$/;
    my $bold_item = $body =~ /^\s*[-*+]\s+\*\*/;
    if ($body =~ /\*\*/ && !$bold_only && !$bold_item) {
        (my $fix = $line) =~ s/\*\*//g;
        $fix =~ s/$spaced//g if $lang{ja};
        add('記号', $no, $line, '本文中の強調', '地の文の一部を太字にしている。', $fix);
    }

    if ($body =~ $emoji) {
        (my $fix = $line) =~ s/\s*$emoji//g;
        add('記号', $no, $line, '装飾絵文字', '装飾の絵文字が入っている。', $fix);
    }

    if ($bold_only) {
        add('文書構成', $no, $line, '見出しの代用', '太字を見出しの代わりに置いている。', undef);
    }

    if ($body =~ /^\s*[^\s|>#-][^|]*[：:]\s*$/) {
        add('文書構成', $no, $line, '見出しの代用', 'コロンで終わる裸の行を見出しの代わりに置いている。', undef);
    }

    if ($bold_item) {
        add('箇条書き', $no, $line, '平坦な箇条書き', '項目名と説明を1行に押し込んでいる。', undef);
    }

    if ($body =~ /^[-*+]\s+.*。./) {
        add('箇条書き', $no, $line, '平坦な箇条書き', '第1階層の項目が句点で文を切るほど長い。', undef);
    }

    if ($line =~ /^\s*[\x{274C}\x{2705}\x{2717}\x{2713}\x{10102}]/) {
        add('修辞', $no, $line, '記号によるbad-then-good比較', 'チェックとバツで対比を作っている。', undef);
    }

    if ($lang{ja}) {
        add('記号', $no, $line, '全角ダッシュ', '英語のem dashをそのまま持ち込んでいる。', undef)
            if $body =~ /──/;
        add('記号', $no, $line, '中黒並列', '地の文の並列を中黒で作っている。', undef)
            if $body =~ /\S・\S/;
        add('記号', $no, $line, '地の文のコロン', '前を予告して後ろで受ける英語のコロンを地の文に持ち込んでいる。', undef)
            if $body =~ /[\p{Hiragana}\p{Katakana}\p{Han}][：:]/ && $body !~ /[：:]\s*$/;
        if ($body =~ $spaced) {
            (my $fix = $line) =~ s/$spaced//g;
            add('記号', $no, $line, '不要な半角スペース', '全角文字との境界に半角スペースが入っている。', $fix);
        }
    }

    add('記号', $no, $line, 'Em dashes', 'em dashで文を繋いでいる。', undef)
        if $lang{en} && $body =~ /[—–]/;

    for my $rule (@LITERAL) {
        next unless $lang{ $rule->{l} };
        for my $term (@{ $rule->{terms} }) {
            my $re = term_re($term, $rule->{l});
            next unless $body =~ $re;
            my $fix;
            if ($rule->{cut}) {
                ($fix = $line) =~ s/$re//;
                $fix =~ s/\s{2,}/ /g;
                $fix =~ s/^\s+|\s+$//g;
                undef $fix if $fix eq '';
            }
            add($rule->{p}, $no, $line, $rule->{c}, "$rule->{problem}（`$term`）", $fix);
            last;
        }
    }

    if ($lang{en}) {
        my @hits = grep { !$LY_STOP{ lc $_ } } ($body =~ /\b([A-Za-z]{3,}ly)\b/g);
        add('語彙', $no, $line, 'Adverbs', 'An -ly adverb standing in for a measurement.（`' . $hits[0] . '`）', undef)
            if @hits;
    }
}

if ($lang{ja}) {
    my %seen_word;
    my %first_line;
    for my $i (0 .. $#lines) {
        next if $skip[$i];
        my $body = masked($lines[$i]);
        for my $rule (@FAMILY) {
            for my $fam (keys %{ $rule->{families} }) {
                for my $w (@{ $rule->{families}{$fam} }) {
                    my $n = () = $body =~ /\Q$w\E/g;
                    next unless $n;
                    $seen_word{ $rule->{c} }{$fam}{$w} += $n;
                    $first_line{ $rule->{c} }{$fam}{$w} //= $i + 1;
                }
            }
        }
    }
    for my $rule (@FAMILY) {
        my $c = $rule->{c};
        next unless $seen_word{$c};
        if (($rule->{mode} // '') eq 'total') {
            my (@words, $total, $line);
            for my $fam (sort keys %{ $seen_word{$c} }) {
                for my $w (sort keys %{ $seen_word{$c}{$fam} }) {
                    push @words, $w;
                    $total += $seen_word{$c}{$fam}{$w};
                    my $l = $first_line{$c}{$fam}{$w};
                    $line = $l if !defined $line || $l < $line;
                }
            }
            next unless $total >= 3;
            add('語彙', $line, $lines[$line - 1], $c,
                '1つの文書で3回以上出ている（' . join('、', @words) . '）', undef);
            next;
        }
        for my $fam (sort keys %{ $seen_word{$c} }) {
            my @words = sort keys %{ $seen_word{$c}{$fam} };
            my @over = grep { $seen_word{$c}{$fam}{$_} >= 3 } @words;
            next unless @words >= 2 || @over;
            my $line = (sort { $a <=> $b } map { $first_line{$c}{$fam}{$_} } @words)[0];
            my $why = @words >= 2
                ? "同じ系統から2語以上出ている（$fam: " . join('、', @words) . '）'
                : "同じ語が3回以上出ている（$fam: " . join('、', @over) . '）';
            add('語彙', $line, $lines[$line - 1], $c, $why, undef);
        }
    }

    my @para;
    for my $i (0 .. $#lines) {
        if ($skip[$i] || $lines[$i] =~ /^\s*$/) {
            check_ja_adverbs(\@para);
            @para = ();
            next;
        }
        push @para, $i;
    }
    check_ja_adverbs(\@para);

    my (@polite, $plain);
    for my $i (0 .. $#lines) {
        next if $skip[$i];
        my $body = masked($lines[$i]);
        push @polite, $i + 1 if $body =~ /(?:です|ます|ました|でした|ません)(?:。|$)/;
        $plain = 1 if $body =~ /(?:だ|である|した|する|ない|いる)。/;
    }
    if (@polite && $plain) {
        add('語彙', $polite[0], $lines[ $polite[0] - 1 ], '文末の敬体',
            '敬体と常体が混ざっている。', undef);
    }
}

sub check_ja_adverbs {
    my $para = shift;
    return unless @$para;
    my (@hits, $count);
    for my $i (@$para) {
        my $body = masked($lines[$i]);
        for my $a (@JA_ADVERBS) {
            my $n = () = $body =~ /\Q$a\E/g;
            next unless $n;
            $count += $n;
            push @hits, $a;
        }
    }
    return unless $count && $count >= 2;
    add('語彙', $para->[0] + 1, $lines[ $para->[0] ], '副詞の重ね掛け',
        '1段落に根拠なし副詞が2個以上ある。（' . join('、', @hits) . '）', undef);
}

sub json_string {
    my $s = shift;
    return 'null' unless defined $s;
    $s =~ s/\\/\\\\/g;
    $s =~ s/"/\\"/g;
    $s =~ s/\n/\\n/g;
    $s =~ s/\t/\\t/g;
    $s =~ s/\r/\\r/g;
    $s =~ s/([\x00-\x1f])/sprintf('\\u%04x', ord $1)/ge;
    return '"' . $s . '"';
}

my @out;
for my $f (@findings) {
    push @out, sprintf(
        '{"perspective":%s,"line":%s,"quote":%s,"category":%s,"problem":%s,"fix":%s}',
        json_string($f->{perspective}),
        $f->{line} =~ /^\d+$/ ? $f->{line} : json_string($f->{line}),
        json_string($f->{quote}),
        json_string($f->{category}),
        json_string($f->{problem}),
        json_string($f->{fix}),
    );
}
print '[', join(',', @out), "]\n";
