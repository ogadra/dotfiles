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
my $in_front = (@lines && $lines[0] eq '---') ? 1 : 0;
for my $i (0 .. $#lines) {
    my $line = $lines[$i];
    if ($in_front) {
        $skip[$i] = 1;
        $in_front = 0 if $i > 0 && $line eq '---';
        next;
    }
    if ($line =~ /^\s*(?:```|~~~)/) {
        $in_code = !$in_code;
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
    my ($line, $quote, $category, $problem, $fix) = @_;
    push @findings, {
        line     => $line,
        quote    => $quote,
        category => $category,
        problem  => $problem,
        fix      => $fix,
    };
}

my $spaced = qr/(?<=[\p{Hiragana}\p{Katakana}\p{Han}]) (?=[\p{Hiragana}\p{Katakana}\p{Han}A-Za-z0-9])|(?<=[A-Za-z0-9]) (?=[\p{Hiragana}\p{Katakana}\p{Han}])/;

my $terminator = qr/[。．.！？!?：:；;」』）】\)\]"']$/;
for my $i (0 .. $#lines - 1) {
    next if $skip[$i] || $skip[$i + 1];
    my ($cur, $next) = ($lines[$i], $lines[$i + 1]);
    next if is_structural($cur) || is_structural($next);
    next if $cur =~ $terminator;
    add(
        ($i + 1) . '-' . ($i + 2),
        "$cur\n$next",
        '文中での改行',
        '文の途中で改行が入っていて、1文が2行に割れている。',
        "$cur $next",
    );
}

for my $i (0 .. $#lines) {
    next if $skip[$i];
    my $line = $lines[$i];
    my $body = masked($line);
    my $no = $i + 1;

    if ($body =~ /\*\*/) {
        (my $fix = $line) =~ s/\*\*//g;
        $fix =~ s/$spaced//g if $lang{ja};
        add($no, $line, '本文中の強調', '地の文の一部を太字にしている。', $fix);
    }

    my $emoji = qr/[\x{1F000}-\x{1FAFF}\x{2600}-\x{26FF}\x{2705}\x{2728}\x{274C}\x{FE0F}]/;
    if ($body =~ $emoji) {
        (my $fix = $line) =~ s/\s*$emoji//g;
        add($no, $line, '装飾絵文字', '装飾の絵文字が入っている。', $fix);
    }

    if ($lang{ja}) {
        if ($body =~ /──/) {
            add($no, $line, '全角ダッシュ', '英語のem dashをそのまま持ち込んでいる。', undef);
        }
        if ($body =~ /\S・\S/) {
            add($no, $line, '中黒並列', '地の文の並列を中黒で作っている。', undef);
        }
        if ($body =~ /[\p{Hiragana}\p{Katakana}\p{Han}][：:]/) {
            add($no, $line, '地の文のコロン', '前を予告して後ろで受ける英語のコロンを地の文に持ち込んでいる。', undef);
        }
        if ($body =~ $spaced) {
            (my $fix = $line) =~ s/$spaced//g;
            add($no, $line, '不要な半角スペース', '全角文字との境界に半角スペースが入っている。', $fix);
        }
    }

    if ($lang{en} && $body =~ /[—–]/) {
        add($no, $line, 'Em dashes', 'em dashで文を繋いでいる。', undef);
    }
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
        '{"line":%s,"quote":%s,"category":%s,"problem":%s,"fix":%s}',
        $f->{line} =~ /^\d+$/ ? $f->{line} : json_string($f->{line}),
        json_string($f->{quote}),
        json_string($f->{category}),
        json_string($f->{problem}),
        json_string($f->{fix}),
    );
}
print '[', join(',', @out), "]\n";
