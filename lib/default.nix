{ lib, pkgs }:
{
  mergeJson = import ./merge-json.nix { inherit lib pkgs; };
}
