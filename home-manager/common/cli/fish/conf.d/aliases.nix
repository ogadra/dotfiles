{ ... }:
{
  programs.fish.shellAliases = {
    rm = "gomi --prune=7d -f >/dev/null 2>&1; gomi";
  };
}
