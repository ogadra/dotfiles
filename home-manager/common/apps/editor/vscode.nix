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
in
{
    programs = {
      vscode = {
        enable = true;
        package = vscode-with-ime;
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
                "files.insertFinalNewline" = true;
            };
            keybindings = import ./vscode-keybindings.nix;
        };
      };
    };
}
