use strict;
use warnings;
use utf8;

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

return {
    literal      => \@LITERAL,
    family       => \@FAMILY,
    ja_adverbs   => \@JA_ADVERBS,
    ly_stop      => \%LY_STOP,
};
