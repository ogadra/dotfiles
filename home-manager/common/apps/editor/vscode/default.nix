{ pkgs, lib, ... }:
let
  vscode-with-ime = pkgs.symlinkJoin {
    name = "code";
    pname = "code";
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --append-flags "--enable-wayland-ime"
    '';
    inherit (pkgs.vscode) version;
    meta.mainProgram = "code";
  };
  vscodePackage = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.vscode else vscode-with-ime;
in
{
    programs = {
      vscode = {
        enable = true;
        package = vscodePackage;
        profiles.default = {
            extensions = with pkgs.vscode-extensions; [
              github.copilot
              golang.go
              mkhl.direnv
              streetsidesoftware.code-spell-checker
            ];
            userSettings = {
                "editor.fontFamily"            = "'CodeNewRoman Nerd Font Mono', 'Droid Sans Mono', 'monospace', monospace";
                "editor.fontLigatures"         = false;
                "editor.formatOnSave"          = true;
                "editor.inlineSuggest.enabled" = true;

                "explorer.confirmDelete" = false;

                "files.autoSave"           = "afterDelay";
                "files.exclude"."**/.git"  = false;
                "files.insertFinalNewline" = true;

                "update.mode" = "none";
                # This key takes the "on"/"off" enum, not a boolean; a boolean is
                # silently ignored and leaves auto update on.
                "extensions.autoUpdate" = "off";
                "extensions.autoCheckUpdates" = false;
                # settings.json is a read-only nix store symlink, so VSCode cannot
                # persist a dismissal of the recommendation prompt by itself.
                "extensions.ignoreRecommendations" = true;

                "cSpell.userWords" = [ "ogadra" ];
            };
            keybindings = import ./keybindings.nix { inherit lib pkgs; };
        };
      };
    };
}
