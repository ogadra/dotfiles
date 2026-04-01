{ pkgs, lib, ... }:
let
  vscode-with-ime = pkgs.symlinkJoin {
    name = "vscode";
    paths = [ pkgs.vscode ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/code \
        --append-flags "--enable-wayland-ime"
    '';
    inherit (pkgs.vscode) pname version;
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
                "extensions.autoUpdate" = false;
                "extensions.autoCheckUpdates" = false;

                "cSpell.userWords" = [ "ogadra" ];
            };
            keybindings = import ./vscode-keybindings.nix;
        };
      };
    };
}
