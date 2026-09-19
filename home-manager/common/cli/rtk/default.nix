{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.rtk ];

  # claude-code の PreToolUse(Bash) hook が rtk へコマンドを書き換える。
  # その挙動を Claude に説明する指示書で、CLAUDE.md から @RTK.md で参照する。
  home.file.".claude/RTK.md".source = ./RTK.md;
}
