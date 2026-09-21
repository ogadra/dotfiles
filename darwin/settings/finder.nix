{ ... }:
{
  # Always show file extensions
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;

  system.defaults.finder = {
    # Show hidden files
    AppleShowAllFiles = true;

    # Default view style: Nlsv=list, icnv=icon, clmv=column, Flwv=gallery
    FXPreferredViewStyle = "Nlsv";
  };
}
