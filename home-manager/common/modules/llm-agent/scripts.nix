{
  pkgs,
  isucon,
  dir,
}:
let
  inherit (pkgs) lib;

  # ISUCON tuning needs sudo, bulk staging, and quick commits, so those guards are left out of the profile entirely
  strict = list: if isucon then [ ] else list;

  topChecks = strict [ "block-sudo.sh" ];
  gitChildren = [
    "block-default-commit.sh"
    "block-default-push.sh"
    "block-force-push.sh"
    "block-rewrite-pushed.sh"
    "block-clone.sh"
    "block-worktree-outside.sh"
  ]
  ++ strict [
    "block-no-verify.sh"
    "block-merge-non-base.sh"
    "block-cherry-pick-stacked.sh"
    "block-commit-all.sh"
    "block-bulk-add.sh"
  ];
  ghChildren = [
    "block-repo-clone.sh"
    "block-pr-close.sh"
  ]
  ++ strict [ "block-pr-body.sh" ];

  # replaceVars drops the exec bit, so replaceVarsWith keeps it on the substituted copy
  substitute =
    src: replacements:
    pkgs.replaceVarsWith {
      inherit src replacements;
      isExecutable = true;
    };

  pick = names: lib.genAttrs names (name: ./scripts + "/${name}");

  files = {
    "pre-bash.sh" = substitute ./scripts/pre-bash.sh {
      checks = toString (
        topChecks
        ++ [
          "git/check.sh"
          "gh/check.sh"
        ]
      );
    };
    "normalize.sh" = ./scripts/normalize.sh;
    "git/check.sh" = substitute ./scripts/git/check.sh { children = toString gitChildren; };
    "gh/check.sh" = substitute ./scripts/gh/check.sh { children = toString ghChildren; };
  }
  // pick topChecks
  // pick (map (name: "git/${name}") gitChildren)
  // pick (map (name: "gh/${name}") ghChildren);
in
# Each entry links to its store copy, so the exec bit of unsubstituted scripts comes from git
lib.mapAttrs' (name: source: lib.nameValuePair "${dir}/${name}" { inherit source; }) files
