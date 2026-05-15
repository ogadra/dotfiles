{
  inputs,
  pkgs,
  ...
}:
let
  claude-code-unwrapped = inputs.llm-agents.packages.${pkgs.system}.claude-code;
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-wrapped";
    paths = [ claude-code-unwrapped ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude \
        --run 'export GIT_CONFIG_GLOBAL="''${GIT_CONFIG_GLOBAL:-$HOME/.claude/config/.gitconfig}"' \
        --set-default GIT_CONFIG_SYSTEM /dev/null
    '';
  };
  ccusage = inputs.llm-agents.packages.${pkgs.system}.ccusage;
  hooksConfig = import ./hooks.nix;

  settingsJson = builtins.toJSON {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";

    ## モデル / 推論

    # 既定モデル。"opus" / "sonnet" / "haiku" などのエイリアス、または完全な model ID。
    model = "opus";
    # 拡張思考の自動有効化。false で thinking 無効、true/未設定で対応モデルでは自動 ON。
    alwaysThinkingEnabled = false;
    # 対応モデル向けの effort レベル（low/medium/high/xhigh）。
    effortLevel = "medium";
    # Fast mode（Opus 4.6 の高速出力モード）の常時有効化。
    fastMode = false;
    # Fast mode をセッションをまたいで保持しない。各セッションは fast mode OFF で開始。
    fastModePerSessionOptIn = false;
    # メインスレッドで使用する agent 名（組み込み or カスタム）。
    # agent = null;
    # サーバーサイドの advisor tool で使用するモデル。
    # advisorModel = null;
    # アシスタント応答の出力スタイル。
    # outputStyle = null;
    # 利用可能モデルの allowlist（managed 設定向け）。
    # availableModels = null;
    # Anthropic model ID → プロバイダ固有 ID のマッピング（managed 設定向け）。
    # modelOverrides = null;

    ## 権限 / フック

    # 許可・拒否ルール（permissions.nix で定義）。
    permissions = import ./permissions.nix;
    # フック定義（hooks.nix で定義）。
    hooks = hooksConfig.hooks;
    # すべての hook と statusLine の実行を無効化するフラグ。
    disableAllHooks = false;
    # managed 設定で hooks の独占を強制（user/project/local の hooks は無視）。
    # allowManagedHooksOnly = null;
    # HTTP hook の URL allowlist。
    # allowedHttpHookUrls = null;
    # HTTP hook が header に展開できる環境変数の allowlist。
    # httpHookAllowedEnvVars = null;
    # managed 設定で permission rule の独占を強制（user/project/local/CLI 引数は無視）。
    # allowManagedPermissionRulesOnly = null;

    ## 表示 / UI

    # Claude の応答および音声入力で優先する言語。
    language = "Japanese";
    # 配色テーマ（auto/dark/light/各daltonized/各ansi または custom:xxx）。
    theme = "dark";
    # プロンプト入力欄のキーバインド（normal/vim）。
    editorMode = "normal";
    # ツール出力を要約せずに全文表示するか。
    verbose = false;
    # 起動時の transcript view モード（default/verbose/focus）。
    viewMode = "default";
    # 既定の transcript view（chat = ユーザー発言のチェックポイントのみ / transcript = 全文）。
    defaultView = "chat";
    # TUI レンダラ。fullscreen は alt-screen＋仮想スクロールバックでちらつきが出にくい。
    tui = "fullscreen";
    # 入力欄の `!` で起動する既定シェル。
    defaultShell = "bash";
    # diff のシンタックスハイライトを無効化するか。
    syntaxHighlightingDisabled = false;
    # `/rename` で端末タブ名を更新するか。false で自動生成タイトルを維持。
    terminalTitleFromRename = true;
    # アクセシビリティ目的でアニメーション（スピナー輝き、フラッシュ等）を抑制。
    prefersReducedMotion = false;
    # transcript view（Ctrl+O）で thinking のサマリを表示するか。
    showThinkingSummaries = false;
    # 各アシスタントターン後に「Cooked for Nm Ns」を表示するか。
    showTurnDuration = true;
    # 各アシスタントメッセージに到達時刻スタンプを付けるか。
    showMessageTimestamps = false;
    # 長時間処理中に OSC 9;4 progress エスケープを emit するか。
    terminalProgressBarEnabled = true;
    # plan 承認ダイアログに "clear context" オプションを出すか。
    showClearContextOnPlanAccept = false;
    # プロンプト候補（サジェスト）機能を有効化するか。
    promptSuggestionEnabled = true;
    # 5分以上離席後の復帰時に表示されるセッション要約を有効化するか。
    awaySummaryEnabled = true;

    ## スピナー / ステータスライン

    # スピナー中の Tips 表示を有効化するか。
    spinnerTipsEnabled = true;
    # スピナー動詞のカスタマイズ（append/replace モード）。
    # spinnerVerbs = null;
    # スピナー Tips のオーバーライド（excludeDefault と tips 配列）。
    # spinnerTipsOverride = null;
    # カスタムステータスライン定義（command 型）。
    statusLine = {
      type = "command";
      command = "$HOME/.claude/scripts/statusline.sh";
      padding = 2;
    };
    # サブエージェントごとのステータスライン定義。
    # subagentStatusLine = null;
    # 起動時に表示する企業アナウンス（複数なら 1 件ランダム選択）。
    # companyAnnouncements = null;
    # PR リンクの URL テンプレート（{host}/{owner}/{repo}/{number}/{url}）。
    # prUrlTemplate = null;

    ## 通知

    # OS 通知チャネル（auto/iterm2/iterm2_with_bell/terminal_bell/kitty/ghostty/notifications_disabled）。
    preferredNotifChannel = "auto";
    # 入力要求／permission prompt 待ち時にモバイルへプッシュ通知するか。
    inputNeededNotifEnabled = true;
    # Claude からの能動的なモバイル通知を許可するか。
    agentPushNotifEnabled = true;

    ## セッション / コンテキスト

    # コンテキストが埋まった際に自動で会話を圧縮するか。
    autoCompactEnabled = true;
    # 自動圧縮のウィンドウサイズ（トークン数。100k〜1M）。
    autoCompactWindow = 200000;
    # 会話 view を底まで自動スクロールするか（fullscreen モード時のみ）。
    autoScrollEnabled = true;
    # /rewind で復元できるよう、編集前にファイルのスナップショットを取るか。
    fileCheckpointingEnabled = true;
    # todo / タスク追跡パネルを有効化するか。
    todoFeatureEnabled = true;
    # transcript の自動保持日数（最小1、既定30）。
    cleanupPeriodDays = 30;

    ## 更新

    # 起動時の自動更新。
    autoUpdates = false;

    ## メモリ / プラン

    # auto-memory 機能の有効化（~/.claude/projects/<cwd>/memory/ への読み書き）。
    autoMemoryEnabled = true;
    # auto-memory の保存先ディレクトリのカスタムパス。
    # autoMemoryDirectory = null;
    # バックグラウンドでの memory 統合（auto-dream）の有効化。
    autoDreamEnabled = true;
    # plan ファイルのカスタムディレクトリ（プロジェクトルートからの相対）。
    # plansDirectory = null;
    # 読み込み除外する CLAUDE.md の glob/絶対パスリスト。
    # claudeMdExcludes = null;

    ## Skill 一覧

    # Claude に渡す skill 一覧の各 description の文字数上限。
    skillListingMaxDescChars = 1536;
    # Claude に渡す skill 一覧が消費する context window の割合（0–1、既定 0.01）。
    skillListingBudgetFraction = 0.01;
    # skill ごとの listing override（on/name-only/user-invocable-only/off）。
    # skillOverrides = null;

    ## ファイル / リポジトリ / Git

    # ファイルピッカーで .gitignore を尊重するか。
    respectGitignore = true;
    # @ メンション時のカスタムファイルサジェスト（command 型）。
    # fileSuggestion = null;
    # コミット／PR の attribution。空文字で非表示にする。
    attribution = {
      commit = "";
      pr = "";
    };
    # コミット／PR ワークフローの組み込み指示をシステムプロンプトに含めるか。
    includeGitInstructions = true;
    # --worktree フラグでの worktree 設定（共有ディレクトリ、sparse-checkout 対象）。
    worktree = {
      symlinkDirectories = [ ];
      sparsePaths = [ ];
    };

    ## Remote / バックグラウンド

    # Remote Control（claude.ai/code 連携）のセッション開始時自動起動。
    remoteControlAtStartup = false;
    # Remote Control 経由で別マシンのピアセッションへ SendMessage する前に明示承認を要求。
    isolatePeerMachines = true;
    # バックグラウンドサービス未起動時の挙動。transient はその場で起動、ask は常駐インストールを提案。
    daemonColdStart = "transient";
    # ローカルセッションを claude.ai に view-only でミラーアップロードするか。
    autoUploadSessions = false;
    # teammate（spawn される別エージェント）の実行モード（auto/tmux/in-process）。
    teammateMode = "auto";
    # remote セッションの既定 environment ID。
    # remote = null;

    ## モード制御

    # plan モードを auto mode セマンティクスで動かすか（auto mode が有効な場合）。
    useAutoModeDuringPlan = true;
    # auto mode 分類器のカスタマイズ（allow/soft_deny/environment）。
    # autoMode = null;
    # bypass permissions モードのダイアログを既読扱いにするか。
    # skipDangerousModePermissionPrompt = null;
    # auto mode オプトインダイアログを既読扱いにするか。
    # skipAutoPermissionPrompt = null;
    # auto mode の無効化（managed 設定向け）。
    # disableAutoMode = null;

    # セッション品質サーベイの出現確率（0–1）。
    feedbackSurveyRate = 0;

    ## Done-means-merged

    # PR が merge 可能になるまで Claude が作業を続ける挙動（@internal）。
    doneMeansMerged = false;

    ## 環境変数

    # Claude Code セッションに設定する環境変数。
    env = { };
  };
in
{
  home.packages = [
    claude-code
    ccusage
  ];

  home.file = {
    ".claude/sounds/notification.mp3".source = ./sounds/notification.mp3;
    ".claude/sounds/stop.mp3".source = ./sounds/stop.mp3;
    ".claude/settings.json".text = settingsJson;
    ".claude/config/.gitconfig".source = ./.gitconfig;
    ".claude/skills/cascade-merge/SKILL.md".source = ./skills/cascade-merge/SKILL.md;
  } // hooksConfig.scripts;
}
