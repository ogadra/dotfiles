{ ... }:
let
  browser = "firefox.desktop";
in
{
  # Declared so removing a browser package cannot silently hand links to another one, as dropping Brave did with Chrome
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "text/html" = browser;
      # Claude Code registers this at runtime, but a Nix-managed mimeapps.list is read-only, so it is kept here
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };
}
