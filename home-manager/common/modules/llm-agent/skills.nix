{
  lib,
  isucon ? false,
}:
let
  orchestrator = builtins.readFile ./skills/orchestrator/SKILL.md;
  noPrPointer = "\n\nユーザーがPRを作らないよう指示したタスクは、末尾の「PRを作らないタスク」に従う。";
  orchestratorParts = lib.splitString "\n## PRを作らないタスク\n" orchestrator;
  # ISUCON lanes always open a PR, so its build cuts the no-PR parts out of the one skill file instead of keeping a second copy that would drift
  isuconOrchestrator =
    assert lib.hasInfix noPrPointer orchestrator;
    assert builtins.length orchestratorParts == 2;
    builtins.toFile "SKILL.md" (
      lib.replaceStrings [ noPrPointer ] [ "" ] (builtins.head orchestratorParts)
    );
in
{
  "absolute-rules/SKILL.md" = ./skills/absolute-rules/SKILL.md;
  "orchestrator/SKILL.md" = if isucon then isuconOrchestrator else ./skills/orchestrator/SKILL.md;
  "ponytail" = ./skills/ponytail;
}
// lib.optionalAttrs (!isucon) {
  "cascade-merge/SKILL.md" = ./skills/cascade-merge/SKILL.md;
  "grill-me" = ./skills/grill-me;
  "import-skill/SKILL.md" = ./skills/import-skill/SKILL.md;
  "pr-create/SKILL.md" = ./skills/pr-create/SKILL.md;
  "pr-review/SKILL.md" = ./skills/pr-review/SKILL.md;
  "pr-review/policies/absolute-rules.md" = ./skills/pr-review/policies/absolute-rules.md;
  "pr-review/policies/ai-antipattern.md" = ./skills/pr-review/policies/ai-antipattern.md;
  "pr-review/policies/architecture.md" = ./skills/pr-review/policies/architecture.md;
  "pr-review/policies/code-quality.md" = ./skills/pr-review/policies/code-quality.md;
  "pr-review/policies/security.md" = ./skills/pr-review/policies/security.md;
  "pr-review/policies/stop-slop.md" = ./skills/pr-review/policies/stop-slop.md;
  "pr-review/policies/testing.md" = ./skills/pr-review/policies/testing.md;
  "readable-writing" = ./skills/readable-writing;
}
