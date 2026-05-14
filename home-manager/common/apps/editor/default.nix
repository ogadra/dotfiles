{ ... }:
let
  editors = [
    ./vscode
    ./emacs
  ];
in
{
  imports = editors;
}
