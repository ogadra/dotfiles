{ hooksConfig }:
{
  "$schema" = "https://json.schemastore.org/claude-code-settings.json";

  ## Model and reasoning

  # An alias such as "opus" / "sonnet" / "haiku", or a full model ID.
  # model = null;
  # false disables extended thinking; true or unset turns it on for models that support it.
  alwaysThinkingEnabled = true;
  # low/medium/high/xhigh, for models that support it.
  effortLevel = "high";
  # Fast mode is Opus 4.6's high-throughput output mode.
  fastMode = false;
  # false keeps Fast mode out of every new session rather than carrying the last choice over.
  fastModePerSessionOptIn = false;
  # Agent used on the main thread, built-in or custom.
  # agent = null;
  # Model used by the server-side advisor tool.
  # advisorModel = null;
  # outputStyle = null;
  # Allowlist of usable models, for managed settings.
  # availableModels = null;
  # Anthropic model ID to provider-specific ID mapping, for managed settings.
  # modelOverrides = null;

  ## Permissions and hooks

  permissions = import ./permissions.nix;
  hooks = hooksConfig.hooks;
  # Kill switch for every hook and for statusLine.
  disableAllHooks = false;
  # Lets managed settings own hooks outright, ignoring user, project, and local ones.
  # allowManagedHooksOnly = null;
  # allowedHttpHookUrls = null;
  # Environment variables an HTTP hook may expand into a header.
  # httpHookAllowedEnvVars = null;
  # Lets managed settings own permission rules outright, ignoring user, project, local, and CLI ones.
  # allowManagedPermissionRulesOnly = null;

  ## Display and UI

  # Covers Claude's responses and voice input.
  language = "Japanese";
  # auto/dark/light, their daltonized and ansi variants, or custom:xxx.
  theme = "custom:nerv";
  # normal/vim.
  editorMode = "normal";
  # true prints tool output in full instead of summarizing it.
  verbose = false;
  # Transcript view at startup: default/verbose/focus.
  viewMode = "default";
  # chat shows only user checkpoints, transcript shows everything.
  defaultView = "chat";
  # "fullscreen" uses the alt screen and virtual scrollback and flickers less, "default" draws on the main screen.
  tui = "default";
  # Shell that `!` in the input line launches.
  defaultShell = "bash";
  # Applies to diffs.
  syntaxHighlightingDisabled = false;
  # false keeps the generated title instead of letting `/rename` retitle the terminal tab.
  terminalTitleFromRename = true;
  # Covers spinner shimmer, flashes, and the like.
  prefersReducedMotion = false;
  # Applies to the transcript view on Ctrl+O.
  showThinkingSummaries = false;
  # Prints "Cooked for Nm Ns" after each assistant turn.
  showTurnDuration = true;
  showMessageTimestamps = false;
  # Emits the OSC 9;4 progress escape during long operations.
  terminalProgressBarEnabled = true;
  showClearContextOnPlanAccept = false;
  promptSuggestionEnabled = true;
  # The summary appears when returning after five minutes away.
  awaySummaryEnabled = true;
  # Idle time before the selected option is taken: "60s"/"5m"/"10m"/"never". v2.1.200+.
  askUserQuestionTimeout = "never";

  ## Voice input

  # This is what /voice writes to.
  voiceEnabled = true;
  # hold records only while the key is down; tap starts on a tap and sends on the next.
  voice = {
    enabled = true;
    mode = "hold";
  };

  ## Spinner and status line

  spinnerTipsEnabled = true;
  # Takes an append or replace mode.
  # spinnerVerbs = null;
  # Takes excludeDefault plus a tips array.
  # spinnerTipsOverride = null;
  statusLine = {
    type = "command";
    command = "$HOME/.claude/scripts/statusline.sh";
    padding = 2;
  };
  # subagentStatusLine = null;
  # One is picked at random when there are several.
  # companyAnnouncements = null;
  # Takes {host}/{owner}/{repo}/{number}/{url}.
  # prUrlTemplate = null;

  ## Notifications

  # auto/iterm2/iterm2_with_bell/terminal_bell/kitty/ghostty/notifications_disabled.
  preferredNotifChannel = "auto";
  # Pushes to mobile while waiting on input or a permission prompt.
  inputNeededNotifEnabled = true;
  # Covers the mobile notifications Claude sends of its own accord.
  agentPushNotifEnabled = true;

  ## Sessions and context

  autoCompactEnabled = false;
  # Tokens, from 100k to 1M.
  autoCompactWindow = 200000;
  # Fullscreen mode only.
  autoScrollEnabled = true;
  # The snapshots are what /rewind restores from.
  fileCheckpointingEnabled = true;
  todoFeatureEnabled = true;
  # Days, minimum 1, default 30.
  cleanupPeriodDays = 30;

  ## Updates

  autoUpdates = false;

  ## Memory and plans

  # Auto-memory reads and writes ~/.claude/projects/<cwd>/memory/.
  autoMemoryEnabled = false;
  # autoMemoryDirectory = null;
  # Auto-dream consolidates memory in the background.
  autoDreamEnabled = false;
  # Relative to the project root.
  # plansDirectory = null;
  # Globs and absolute paths of CLAUDE.md files to leave unread.
  # claudeMdExcludes = null;

  ## Skill listing

  skillListingMaxDescChars = 1536;
  # Share of the context window the listing may consume, 0 to 1, default 0.01.
  skillListingBudgetFraction = 0.01;
  # on/name-only/user-invocable-only/off, per skill.
  # skillOverrides = null;

  ## Files, repositories, and Git

  # Applies to the file picker.
  respectGitignore = true;
  # Custom suggestions for @ mentions, command type.
  # fileSuggestion = null;
  # An empty string hides the attribution.
  attribution = {
    pr = "";
  };
  # Puts the built-in commit and PR workflow instructions in the system prompt.
  includeGitInstructions = true;
  # Used by the --worktree flag.
  worktree = {
    symlinkDirectories = [ ];
    sparsePaths = [ ];
  };

  ## Remote and background

  # Remote Control is the claude.ai/code integration.
  remoteControlAtStartup = false;
  # Asks before SendMessage reaches a peer session on another machine.
  isolatePeerMachines = true;
  # transient starts a background service on the spot, ask offers to install a resident one.
  daemonColdStart = "transient";
  # The uploads are view-only mirrors of local sessions.
  autoUploadSessions = false;
  # How spawned teammate agents run: auto/tmux/in-process.
  teammateMode = "auto";
  # Default environment ID for remote sessions.
  # remote = null;

  ## Mode control

  # Only bites when auto mode is on.
  useAutoModeDuringPlan = true;
  # Takes allow/soft_deny/environment.
  # autoMode = null;
  # Treats the bypass permissions dialog as already read.
  # skipDangerousModePermissionPrompt = null;
  # Treats the auto mode opt-in dialog as already read.
  # skipAutoPermissionPrompt = null;
  # For managed settings.
  # disableAutoMode = null;

  # Odds the survey appears, 0 to 1.
  feedbackSurveyRate = 0;

  ## Done-means-merged

  # Keeps Claude working until the PR can merge (@internal).
  doneMeansMerged = false;

  ## Environment variables

  env = { };
}
