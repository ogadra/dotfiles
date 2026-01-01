{ ... }:
let
  vscode = [
    ./vscode.nix
  ];
in
{
  imports = vscode;
}
