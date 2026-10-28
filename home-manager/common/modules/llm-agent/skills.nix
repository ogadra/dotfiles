{
  lib,
  isucon ? false,
}:
{
  "absolute-rules/SKILL.md" = ./skills/absolute-rules/SKILL.md;
  "orchestrator/SKILL.md" = ./skills/orchestrator/SKILL.md;
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
