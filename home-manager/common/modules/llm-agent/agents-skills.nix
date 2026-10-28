{
  lib,
  isucon ? false,
  ...
}:
let
  skills = import ./skills.nix { inherit lib isucon; };
in
{
  # Codex and Devin both scan ~/.agents/skills, so each imports this module and the module system installs it once
  home.file = lib.mapAttrs' (
    path: source: lib.nameValuePair ".agents/skills/${path}" { inherit source; }
  ) skills;
}
