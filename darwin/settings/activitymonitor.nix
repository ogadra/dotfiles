{ ... }:
{
  system.defaults.ActivityMonitor = {
    # Processes listed: 100=all, 101=hierarchy, 102=mine, 103=system, 104=other users, 105=active, 106=inactive, 107=windowed
    ShowCategory = 102;

    # Dock icon: 0=app icon, 2=network, 3=disk, 5=CPU, 6=CPU history
    IconType = 0;

    # Sort column
    SortColumn = "Command";

    # Sort direction: 0=descending, 1=ascending
    SortDirection = 1;

    # Open the main window at launch
    OpenMainWindow = true;
  };
}
