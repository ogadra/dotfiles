{ ... }:
{
    programs = {
      vscode = {
        enable = true;
        profiles.default = {
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
