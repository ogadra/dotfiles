{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.rtk ];

  # Explains to Claude why its PreToolUse(Bash) hook rewrites commands into rtk; CLAUDE.md pulls it in as @RTK.md
  home.file.".claude/RTK.md".source = ./RTK.md;
}
