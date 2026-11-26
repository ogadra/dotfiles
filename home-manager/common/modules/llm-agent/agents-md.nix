{
  pkgs,
  isucon,
  questions,
}:
# The isucon profile drops the git, PR and code-writing rules and keeps only how to hand commands to and ask the user.
pkgs.replaceVars (if isucon then ./isucon.AGENTS.md else ./AGENTS.md) {
  # Each agent names a different question tool with a different schema, so the rules come from the agent's own module.
  questions = pkgs.lib.removeSuffix "\n" (builtins.readFile questions);
}
