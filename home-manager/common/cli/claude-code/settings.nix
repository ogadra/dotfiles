{ hooksConfig }:
{
  "$schema" = "https://json.schemastore.org/claude-code-settings.json";

  ## Model and reasoning

  # Default model: an alias such as "opus" / "sonnet" / "haiku", or a full model ID.
  # model = null;
  # false disables extended thinking; true or unset turns it on for models that support it.
  alwaysThinkingEnabled = true;
  # Effort level for models that support it: low/medium/high/xhigh.
  effortLevel = "high";
  # Fast mode, Opus 4.6's high-throughput output mode, on at all times.
  fastMode = false;
  # false keeps Fast mode out of every new session rather than carrying the last choice over.
  fastModePerSessionOptIn = false;
  # Agent used on the main thread, built-in or custom.
  # agent = null;
  # Model used by the server-side advisor tool.
  # advisorModel = null;
  # Output style for assistant responses.
  # outputStyle = null;
  # Allowlist of usable models, for managed settings.
  # availableModels = null;
  # Anthropic model ID to provider-specific ID mapping, for managed settings.
  # modelOverrides = null;

  ## Permissions and hooks

  # Allow and deny rules.
  permissions = import ./permissions.nix;
  # Hook definitions.
  hooks = hooksConfig.hooks;
  # Kill switch for every hook and for statusLine.
  disableAllHooks = false;
  # Lets managed settings own hooks outright, ignoring user, project, and local ones.
  # allowManagedHooksOnly = null;
  # URL allowlist for HTTP hooks.
  # allowedHttpHookUrls = null;
  # Environment variables an HTTP hook may expand into a header.
  # httpHookAllowedEnvVars = null;
  # Lets managed settings own permission rules outright, ignoring user, project, local, and CLI ones.
  # allowManagedPermissionRulesOnly = null;

  ## Display and UI

  # Language for Claude's responses and voice input.
  language = "Japanese";
  # Color theme: auto/dark/light, their daltonized and ansi variants, or custom:xxx.
  theme = "custom:nerv";
  # Key bindings in the prompt input: normal/vim.
  editorMode = "normal";
  # true prints tool output in full instead of summarizing it.
  verbose = false;
  # Transcript view at startup: default/verbose/focus.
  viewMode = "default";
  # Default transcript view: chat shows only user checkpoints, transcript shows everything.
  defaultView = "chat";
  # TUI renderer: "fullscreen" uses the alt screen and virtual scrollback and flickers less, "default" draws on the main screen.
  tui = "default";
  # Shell that `!` in the input line launches.
  defaultShell = "bash";
  # Syntax highlighting in diffs.
  syntaxHighlightingDisabled = false;
  # false keeps the generated title instead of letting `/rename` retitle the terminal tab.
  terminalTitleFromRename = true;
  # Suppress animation such as spinner shimmer and flashes, for accessibility.
  prefersReducedMotion = false;
  # Thinking summaries in the transcript view on Ctrl+O.
  showThinkingSummaries = false;
  # Prints "Cooked for Nm Ns" after each assistant turn.
  showTurnDuration = true;
  # Stamp each assistant message with the time it arrived.
  showMessageTimestamps = false;
  # Emits the OSC 9;4 progress escape during long operations.
  terminalProgressBarEnabled = true;
  # "clear context" option in the plan approval dialog.
  showClearContextOnPlanAccept = false;
  # Prompt suggestions.
  promptSuggestionEnabled = true;
  # Session summary shown when returning after five minutes away.
  awaySummaryEnabled = true;
  # Idle time before the selected option is taken: "60s"/"5m"/"10m"/"never". v2.1.200+.
  askUserQuestionTimeout = "never";

  ## Voice input

  # Dictation; this is what /voice writes to.
  voiceEnabled = true;
  # mode hold records only while the key is down; tap starts on a tap and sends on the next.
  voice = {
    enabled = true;
    mode = "hold";
  };

  ## Spinner and status line

  # Tips shown while the spinner runs.
  spinnerTipsEnabled = true;
  # Custom spinner verbs, in append or replace mode.
  # spinnerVerbs = null;
  # Spinner tip overrides, as excludeDefault plus a tips array.
  # spinnerTipsOverride = null;
  # Custom status line definition.
  statusLine = {
    type = "command";
    command = "$HOME/.claude/scripts/statusline.sh";
    padding = 2;
  };
  # Per-subagent status line definition.
  # subagentStatusLine = null;
  # Announcements shown at startup; one is picked at random when there are several.
  # companyAnnouncements = null;
  # URL template for PR links: {host}/{owner}/{repo}/{number}/{url}.
  # prUrlTemplate = null;

  ## Notifications

  # OS notification channel: auto/iterm2/iterm2_with_bell/terminal_bell/kitty/ghostty/notifications_disabled.
  preferredNotifChannel = "auto";
  # Push to mobile while waiting on input or a permission prompt.
  inputNeededNotifEnabled = true;
  # Mobile notifications Claude sends of its own accord.
  agentPushNotifEnabled = true;

  ## Sessions and context

  # Compact the conversation once the context fills.
  autoCompactEnabled = false;
  # Window size for automatic compaction, in tokens, from 100k to 1M.
  autoCompactWindow = 200000;
  # Auto-scroll the conversation view, fullscreen mode only.
  autoScrollEnabled = true;
  # Snapshot files before editing them; this is what /rewind restores from.
  fileCheckpointingEnabled = true;
  # Todo and task tracking panel.
  todoFeatureEnabled = true;
  # Days a transcript is kept, minimum 1, default 30.
  cleanupPeriodDays = 30;

  ## Updates

  # Update at startup.
  autoUpdates = false;

  ## Memory and plans

  # Auto-memory, which reads and writes ~/.claude/projects/<cwd>/memory/.
  autoMemoryEnabled = false;
  # Custom path for the auto-memory directory.
  # autoMemoryDirectory = null;
  # Auto-dream, which consolidates memory in the background.
  autoDreamEnabled = false;
  # Custom directory for plan files, relative to the project root.
  # plansDirectory = null;
  # Globs and absolute paths of CLAUDE.md files to leave unread.
  # claudeMdExcludes = null;

  ## Skill listing

  # Character cap on each description in the skill listing.
  skillListingMaxDescChars = 1536;
  # Share of the context window the listing may consume, 0 to 1, default 0.01.
  skillListingBudgetFraction = 0.01;
  # Per-skill listing override: on/name-only/user-invocable-only/off.
  # skillOverrides = null;

  ## Files, repositories, and Git

  # Honor .gitignore in the file picker.
  respectGitignore = true;
  # Custom file suggestions for @ mentions.
  # fileSuggestion = null;
  # PR attribution; an empty string hides it.
  attribution = {
    pr = "";
  };
  # Put the built-in commit and PR workflow instructions in the system prompt.
  includeGitInstructions = true;
  # Worktree settings for the --worktree flag.
  worktree = {
    symlinkDirectories = [ ];
    sparsePaths = [ ];
  };

  ## Remote and background

  # Start Remote Control, the claude.ai/code integration, when a session opens.
  remoteControlAtStartup = false;
  # Ask before SendMessage reaches a peer session on another machine.
  isolatePeerMachines = true;
  # Background service cold start: transient starts one on the spot, ask offers to install a resident one.
  daemonColdStart = "transient";
  # Mirror local sessions to claude.ai as view-only uploads.
  autoUploadSessions = false;
  # How spawned teammate agents run: auto/tmux/in-process.
  teammateMode = "auto";
  # Default environment ID for remote sessions.
  # remote = null;

  ## Mode control

  # Run plan mode under auto mode semantics; only bites when auto mode is on.
  useAutoModeDuringPlan = true;
  # Auto mode classifier customization: allow/soft_deny/environment.
  # autoMode = null;
  # Treat the bypass permissions dialog as already read.
  # skipDangerousModePermissionPrompt = null;
  # Treat the auto mode opt-in dialog as already read; defaultMode already picks auto, so the dialog asks nothing new.
  skipAutoPermissionPrompt = true;
  # Disable auto mode, for managed settings.
  # disableAutoMode = null;

  # Odds the session quality survey appears, 0 to 1.
  feedbackSurveyRate = 0;

  ## Done-means-merged

  # Keep Claude working until the PR can merge (@internal).
  doneMeansMerged = false;

  ## Environment variables

  # Environment variables set for a Claude Code session.
  env = { };
}
