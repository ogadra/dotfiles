use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use File::Basename qw(dirname);
use File::Spec;
use File::Temp qw(tempfile);

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
    if ($line =~ /^Co-Authored-By:/i) {
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

sub outside_masked {
    my ($line, $edit) = @_;
    return join '', map { /^(?:`[^`]*`|https?:\/\/\S+)$/ ? $_ : $edit->($_) }
        split /(`[^`]*`|https?:\/\/\S+)/, $line, -1;
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
    my ($term, $l, $before) = @_;
    my @parts = split /〜|○○|\[X\]/, $term, -1;
    my $pat = join('.{0,25}', map { quotemeta } @parts);
    $pat = "(?<=$before)$pat" if defined $before;
    if ($l eq 'en') {
        $pat = '\b' . $pat if $term =~ /^\w/;
        $pat = $pat . '\b' if $term =~ /\w$/;
        return qr/$pat/i;
    }
    return qr/$pat/;
}

# Word lists live in per-language files, so bake the language that was read into every rule
my $rules_dir = File::Spec->catdir(dirname(__FILE__), 'rules');
my (@LITERAL, @FAMILY, @VARIANTS, @JA_ADVERBS, %LY_STOP);
for my $l (sort keys %lang) {
    my $path = File::Spec->catfile($rules_dir, "$l.pl");
    my $rules = do($path)
        or die "mechanical.pl: cannot load $path: $@$!\n";
    push @LITERAL, map { { %$_, l => $l } } @{ $rules->{literal} // [] };
    push @FAMILY,  map { { %$_, l => $l } } @{ $rules->{family}  // [] };
    push @VARIANTS, @{ $rules->{variants} // [] };
    push @JA_ADVERBS, @{ $rules->{adverbs} // [] };
    $LY_STOP{$_} = 1 for keys %{ $rules->{ly_stop} // {} };
}

for my $rule (@LITERAL) {
    next unless $rule->{c} eq 'Adverbs';
    $LY_STOP{ lc $_ } = 1 for @{ $rule->{terms} };
}

my $spaced = qr/(?<=[\p{Hiragana}\p{Katakana}\p{Han}]) (?=[\p{Hiragana}\p{Katakana}\p{Han}A-Za-z0-9])|(?<=[A-Za-z0-9]) (?=[\p{Hiragana}\p{Katakana}\p{Han}])/;
my $terminator = qr/[。．.！？!?：:；;」』）】\)\]"']$/;
my $emoji = qr/[\x{1F000}-\x{1FAFF}\x{2600}-\x{26FF}\x{2705}\x{2728}\x{274C}\x{FE0F}]/;

my $comma_head = qr/(?:は|では|には|で|から|まで|までに|に|も)$/;
my %comma_keep_head = map { $_ => 1 } qw(では それでは これでは 実は 要は 特に さらに 次に 最後に 最初に 逆に 同時に 実際に);
my $comma_clause_before = qr/(?:る|た|い|ない)(?:まで|までは|うちは|ときは|時は|前は|あとは|後は)$/;
my $comma_clause_after = qr/(?:てから|でから|たら|だら|れば|ので|ながら|つつ)[^、。]{2,}/;
my $comma_keep_de = qr/(?:無料|有料|簡単|可能|不要|必要|便利|安全|丁寧|元気|静か)で$/;

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
        my $fix = outside_masked($line, sub {
            (my $s = shift) =~ s/\*\*//g;
            $s =~ s/$spaced//g if $lang{ja};
            return $s;
        });
        add('記号', $no, $line, '本文中の強調', '地の文の一部を太字にしている。', $fix);
    }

    if ($body =~ $emoji) {
        my $fix = outside_masked($line, sub { (my $s = shift) =~ s/\s*$emoji//g; return $s });
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
            if $body =~ /──|[—―━]/;
        add('記号', $no, $line, '中黒並列', '地の文の並列を中黒で作っている。', undef)
            if $body =~ /\S・\S/;
        add('記号', $no, $line, '地の文のコロン', '前を予告して後ろで受ける英語のコロンを地の文に持ち込んでいる。', undef)
            if $body =~ /[\p{Hiragana}\p{Katakana}\p{Han}][：:]/ && $body !~ /[：:]\s*$/;
        if ($body =~ $spaced) {
            my $fix = outside_masked($line, sub { (my $s = shift) =~ s/$spaced//g; return $s });
            add('記号', $no, $line, '不要な半角スペース', '全角文字との境界に半角スペースが入っている。', $fix);
        }
        check_ja_commas($no, $line, $body) unless $body =~ /^\s*\|/;
        if ($body =~ /[０-９Ａ-Ｚａ-ｚ]/) {
            my $fix = outside_masked($line, sub { (my $s = shift) =~ tr/０-９Ａ-Ｚａ-ｚ/0-9A-Za-z/; return $s });
            add('記号', $no, $line, '全角の英数字', '和文の中の英数字を全角で書いている。', $fix);
        }
    }

    add('記号', $no, $line, 'Em dashes', 'em dashで文を繋いでいる。', undef)
        if $lang{en} && $body =~ /[—–]/;

    for my $rule (@LITERAL) {
        for my $term (@{ $rule->{terms} }) {
            my $re = term_re($term, $rule->{l}, $rule->{before});
            next unless $body =~ $re;
            my $fix;
            if ($rule->{cut}) {
                my $cut = 0;
                $fix = outside_masked($line, sub {
                    my $s = shift;
                    return $s if $cut;
                    return $s unless $s =~ /$re(?:\s*[、，,])?[ \t　]*/;
                    my ($before, $removed, $rest) = (substr($s, 0, $-[0]), substr($s, $-[0], $+[0] - $-[0]), substr($s, $+[0]));
                    $rest =~ s/^([a-z])/\u$1/ if $removed =~ /^[A-Z]/ && $rest !~ /^[a-z]+[A-Z]/;
                    $cut = 1;
                    return $before . $rest;
                });
                $fix = outside_masked($fix, sub { (my $s = shift) =~ s/\s{2,}/ /g; return $s });
                $fix =~ s/^\s+|\s+$//g;
                undef $fix if $fix eq '' || !$cut;
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

    check_ja_no_chains();

    for my $group (@VARIANTS) {
        my %first;
        for my $i (0 .. $#lines) {
            next if $skip[$i];
            my $body = masked($lines[$i]);
            for my $form (keys %$group) {
                next if $first{$form};
                $first{$form} = [$i + 1, $-[0]] if $body =~ /(?:$group->{$form})(?![ァ-ヴー])/;
            }
        }
        next unless keys %first >= 2;
        my @forms = sort { $first{$a}[0] <=> $first{$b}[0] || $first{$a}[1] <=> $first{$b}[1] } keys %first;
        my $line = $first{ $forms[1] }[0];
        add('語彙', $line, $lines[$line - 1], '表記ゆれ',
            '同じ語を2通り以上に書いている。（' . join('、', @forms) . '）', undef);
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
            '敬体と常体が混ざっている。',
            '文書全体を常体に書き換える。体言止めもこれに入る。敬体に揃える形は取らない。');
    }
}

sub check_ja_commas {
    my ($no, $line, $body) = @_;
    for my $s (split /(?<=[。！？])/, $body) {
        (my $core = $s) =~ s/^\s*(?:#+|[-*+]|\d+\.)\s+//;
        $core =~ s/^\s+|\s+$//g;
        my $commas = () = $core =~ /、/g;
        next unless $commas;

        my $objects = () = $core =~ /を、/g;
        if ($objects == 1) {
            my $fix;
            $fix = outside_masked($line, sub { (my $s = shift) =~ s/を、/を/; return $s })
                if (() = $body =~ /を、/g) == 1;
            add('記号', $no, $line, '間を作る読点', '`を` のあとに読点を打っている。', $fix);
            next;
        }

        next unless $commas == 1 && length($core) <= 36;
        my ($before, $after) = split /、/, $core, 2;
        my ($head) = $before =~ /([^「」（）()\s]*)$/;
        next unless length($head) <= 9 && $head =~ $comma_head;
        next if $comma_keep_head{$head} || $head =~ /つ目(?:は|に)$/;
        next if $head =~ $comma_clause_before || $head =~ $comma_keep_de;
        next if $after =~ $comma_clause_after;
        next if $after =~ /^[^、。]{1,10}が/;
        next if $after =~ /^[^、。]{1,12}(?:は|も)/ && substr($before, 0, -1) =~ /(?:は|も)/;
        my $cut = 0;
        my $fix = outside_masked($line, sub {
            my $s = shift;
            $cut = 1 if !$cut && $s =~ s/\Q$head\E、/$head/;
            return $s;
        });
        undef $fix unless $cut;
        add('記号', $no, $line, '間を作る読点', "文頭の短い主題のあとに読点で間を作っている。（`$head、`）", $fix);
    }
}

my $mecab_tokens;
sub mecab_tokens {
    return $mecab_tokens if $mecab_tokens;
    my ($fh, $path) = tempfile(UNLINK => 1);
    binmode $fh, ':encoding(UTF-8)';
    print $fh (($skip[$_] ? '' : masked($lines[$_])) . "\n") for 0 .. $#lines;
    close $fh or die "mechanical.pl: cannot write $path: $!\n";
    open my $out, '-|', 'mecab', $path or die "mechanical.pl: cannot run mecab: $!\n";
    my (@sentences, @current);
    while (my $row = <$out>) {
        chomp $row;
        if ($row eq 'EOS') {
            push @sentences, [@current];
            @current = ();
            next;
        }
        my ($surface, $feature) = split /\t/, $row, 2;
        my @f = split /,/, $feature;
        push @current, { surface => $surface, pos => $f[0], sub1 => $f[1], base => $f[6] };
    }
    close $out or die "mechanical.pl: mecab failed (status $?)\n";
    die 'mechanical.pl: mecab returned ' . scalar(@sentences) . ' sentences for ' . scalar(@lines) . " lines\n"
        unless @sentences == @lines;
    $mecab_tokens = \@sentences;
    return $mecab_tokens;
}

sub check_ja_no_chains {
    my $tokens = mecab_tokens();
    for my $i (0 .. $#lines) {
        next if $skip[$i];
        my @units;
        for my $t (@{ $tokens->[$i] }) {
            if ($t->{pos} eq '名詞' || $t->{pos} eq '接頭詞') {
                if (@units && $units[-1]{kind} eq 'noun') {
                    $units[-1]{text} .= $t->{surface};
                    $units[-1]{sahen} = $t->{pos} eq '名詞' && $t->{sub1} eq 'サ変接続';
                } else {
                    push @units, { kind => 'noun', text => $t->{surface}, sahen => $t->{pos} eq '名詞' && $t->{sub1} eq 'サ変接続' };
                }
            } elsif ($t->{pos} eq '助詞' && $t->{sub1} eq '連体化' && $t->{surface} eq 'の') {
                push @units, { kind => 'no', text => 'の' };
            } else {
                push @units, { kind => 'other' };
            }
        }
        my $start = 0;
        while ($start < @units) {
            if ($units[$start]{kind} ne 'noun') {
                $start++;
                next;
            }
            my $end = $start;
            $end += 2 while $end + 2 <= $#units && $units[ $end + 1 ]{kind} eq 'no' && $units[ $end + 2 ]{kind} eq 'noun';
            my $links = ($end - $start) / 2;
            my $sahen = grep { $units[$_]{sahen} } grep { ($_ - $start) % 2 == 0 } $start .. $end;
            if ($links >= 3 && $sahen >= 2) {
                my $chain = join '', map { $units[$_]{text} } $start .. $end;
                add('修辞', $i + 1, $lines[$i], '「の」の連続',
                    "動作の名詞を含む語を「の」で3つ以上重ねている。（`$chain`）", undef);
            }
            $start = $end + 1;
        }
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
