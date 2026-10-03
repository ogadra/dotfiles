{ inputs, ... }:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma.enable = true;
  programs.plasma.input = {
    keyboard = {
      # numlockOnStartup accepts: on, off, unchanged
      numlockOnStartup = "off";
      # Key repeat delay in milliseconds
      repeatDelay = 200;
    };
    # vendorId/productId are hex strings as shown in /proc/bus/input/devices
    touchpads = [
      {
        name = "ELAN0676:00 04F3:3195 Touchpad";
        vendorId = "04f3";
        productId = "3195";
        naturalScroll = true;
        # Pointer acceleration, range -1.0 to 1.0
        pointerSpeed = 1.0;
      }
    ];
    mice = [
      {
        name = "ELECOM TrackBall Mouse DEFT Pro TrackBall";
        vendorId = "056e";
        productId = "0132";
        # Pointer acceleration, range -1.0 to 1.0
        acceleration = 1.0;
      }
    ];
  };
}
