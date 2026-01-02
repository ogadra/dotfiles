{
  inputs,
  ...
}:
{
  imports = [
    inputs.claude-code-overlay.homeManagerModules.default
  ];
  programs.claude-code.enable = true;
  home.sessionPath = [ "$HOME/.local/bin" ];
}
