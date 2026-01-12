{ pkgs, ... }:
{
    programs = {
      vscode = {
        enable = true;
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
