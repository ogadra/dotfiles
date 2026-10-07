{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.rtk ];

  # Explains to the agents why their PreToolUse(Bash) hook rewrites commands into rtk; the shared AGENTS.md pulls it in as @RTK.md
  home.file.".claude/RTK.md".source = ./RTK.md;
}
