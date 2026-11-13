{ ... }:
{
  programs.fish.shellAliases = {
    # gomi has no retention setting, and a systemd timer or launchd agent misses runs while the laptop is off, so prune on every rm
    rm = "gomi --prune=7d -f >/dev/null 2>&1; gomi";
  };
}
