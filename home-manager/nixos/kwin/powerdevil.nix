{ ... }:
{
  programs.plasma.powerdevil = {
    AC = {
      autoSuspend.action = "nothing";
      whenLaptopLidClosed = "doNothing";
      dimDisplay.enable = false;
      turnOffDisplay.idleTimeout = "never";
    };
    battery = {
      autoSuspend.action = "nothing";
      whenLaptopLidClosed = "lockScreen";
      # Display power-off timeout in seconds
      turnOffDisplay.idleTimeout = 300;
    };
  };

  # WhenLockedSec=5 sits below the typed option's 20 second minimum
  programs.plasma.configFile."powerdevilrc"."Battery/Display" = {
    TurnOffDisplayWhenIdle = true;
    TurnOffDisplayIdleTimeoutWhenLockedSec = 5;
  };
}
