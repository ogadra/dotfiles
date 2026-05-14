{ ... }:
{
  xdg.configFile."powerdevilrc".text = ''
    [AC][Display]
    DimDisplayIdleTimeoutSec=-1
    DimDisplayWhenIdle=false
    TurnOffDisplayIdleTimeoutSec=-1
    TurnOffDisplayWhenIdle=false

    [AC][SuspendAndShutdown]
    AutoSuspendAction=0
    LidAction=0

    [Battery][Display]
    TurnOffDisplayWhenIdle=true
    TurnOffDisplayIdleTimeoutSec=5
    TurnOffDisplayIdleTimeoutWhenLockedSec=5

    [Battery][SuspendAndShutdown]
    AutoSuspendAction=0
    LidAction=32
  '';
}
