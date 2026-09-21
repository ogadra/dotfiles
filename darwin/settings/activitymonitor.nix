{ ... }:
{
  system.defaults.ActivityMonitor = {
    # 100=all, 101=hierarchy, 102=mine, 103=system, 104=other users, 105=active, 106=inactive, 107=windowed
    ShowCategory = 102;

    # 0=app icon, 2=network, 3=disk, 5=CPU, 6=CPU history
    IconType = 0;

    SortColumn = "Command";

    # 0=descending, 1=ascending
    SortDirection = 1;

    OpenMainWindow = true;
  };
}
