{
  isucon ? false,
}:
let
  # executable = true makes home-manager copy the file to set its mode, so the exec bit lives in git and the file stays a symlink to the store
  mkScript = src: { source = src; };
  shared = ../../modules/llm-agent;
in
{
  # Devin reads Claude Code's hook schema, so event names and the command type carry over unchanged
  hooks = {
    PreToolUse = [
      {
        # Devin's shell tool is lowercase "exec", so Claude's "Bash" matcher never fires here
        matcher = "^exec$";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/pre-bash.sh";
          }
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/rtk-hook.sh";
          }
        ];
      }
    ];
    PostToolUse = [
      {
        matcher = "^(edit|write|notebook_edit)$";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/ensure-trailing-newline.sh";
          }
        ];
      }
    ];
    UserPromptSubmit = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/herdr-name-tab.sh --model swe-2";
          }
        ];
      }
    ];
    Stop = [
      {
        matcher = "";
        hooks = [
          {
            type = "command";
            command = "$HOME/.config/devin/scripts/herdr-name-tab.sh";
          }
        ];
      }
    ];
  };

  scripts = {
    ".config/devin/scripts/pre-bash.sh" = mkScript (shared + "/scripts/pre-bash.sh");
    ".config/devin/scripts/normalize.sh" = mkScript (shared + "/scripts/normalize.sh");
    ".config/devin/scripts/rtk-hook.sh" = mkScript (shared + "/scripts/rtk-hook.sh");
    ".config/devin/scripts/herdr-name-tab.sh" = mkScript (shared + "/scripts/herdr-name-tab.sh");
    ".config/devin/scripts/ensure-trailing-newline.sh" = mkScript (
      shared + "/scripts/ensure-trailing-newline.sh"
    );
    ".config/devin/scripts/git/check.sh" = mkScript (shared + "/scripts/git/check.sh");
    ".config/devin/scripts/git/block-default-commit.sh" = mkScript (
      shared + "/scripts/git/block-default-commit.sh"
    );
    ".config/devin/scripts/git/block-default-push.sh" = mkScript (
      shared + "/scripts/git/block-default-push.sh"
    );
    ".config/devin/scripts/git/block-force-push.sh" = mkScript (
      shared + "/scripts/git/block-force-push.sh"
    );
    ".config/devin/scripts/git/block-rewrite-pushed.sh" = mkScript (
      shared + "/scripts/git/block-rewrite-pushed.sh"
    );
    ".config/devin/scripts/git/block-clone.sh" = mkScript (shared + "/scripts/git/block-clone.sh");
    ".config/devin/scripts/git/block-worktree-outside.sh" = mkScript (
      shared + "/scripts/git/block-worktree-outside.sh"
    );
    ".config/devin/scripts/gh/check.sh" = mkScript (shared + "/scripts/gh/check.sh");
    ".config/devin/scripts/gh/block-repo-clone.sh" = mkScript (
      shared + "/scripts/gh/block-repo-clone.sh"
    );
    ".config/devin/scripts/gh/block-pr-close.sh" = mkScript (shared + "/scripts/gh/block-pr-close.sh");
    ".config/devin/scripts/gh/block-reply.sh" = mkScript (shared + "/scripts/gh/block-reply.sh");
  }
  // (
    if isucon then
      { }
    else
      {
        ".config/devin/scripts/block-sudo.sh" = mkScript (shared + "/scripts/block-sudo.sh");
        ".config/devin/scripts/git/block-no-verify.sh" = mkScript (
          shared + "/scripts/git/block-no-verify.sh"
        );
        ".config/devin/scripts/git/block-merge-non-base.sh" = mkScript (
          shared + "/scripts/git/block-merge-non-base.sh"
        );
        ".config/devin/scripts/git/block-cherry-pick-stacked.sh" = mkScript (
          shared + "/scripts/git/block-cherry-pick-stacked.sh"
        );
        ".config/devin/scripts/git/block-commit-all.sh" = mkScript (
          shared + "/scripts/git/block-commit-all.sh"
        );
        ".config/devin/scripts/git/block-bulk-add.sh" = mkScript (
          shared + "/scripts/git/block-bulk-add.sh"
        );
        ".config/devin/scripts/gh/block-pr-body.sh" = mkScript (shared + "/scripts/gh/block-pr-body.sh");
      }
  );
}
