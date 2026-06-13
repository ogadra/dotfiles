{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = [ inputs.llm-agents.packages.${system}.ccusage ];
}
