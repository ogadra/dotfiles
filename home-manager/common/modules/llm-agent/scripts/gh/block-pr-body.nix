{ pkgs, inputs }:
let
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = inputs.self.outPath; };
  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages { python = pkgs.python315; }).overrideScope
      (
        pkgs.lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.wheel
          (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
        ]
      );
  venv = pythonSet.mkVirtualEnv "block-pr-body-env" workspace.deps.default;
in
pkgs.writers.makeScriptWriter { interpreter = "${venv}/bin/python"; } "block-pr-body" (
  builtins.readFile ./block_pr_body.py
)
