{ ... }:
{
  services.xremap = {
    enable     = true;
    watch      = true;
    config = {
      modmap = [
        {
          name = "internal-kbd-swap-capslock-ctrl";
          device.only = [ "AT Translated Set 2 keyboard" ];
          remap = {
            CAPSLOCK = "LEFTCTRL";
            LEFTCTRL = "CAPSLOCK";
          };
        }
        {
          name = "hhkb-swap-alt-super";
          device.only = [ "HHKB" ];
          remap = {
            LEFTALT = "LEFTMETA";
            LEFTMETA = "LEFTALT";
            RIGHTALT = "RIGHTMETA";
            RIGHTMETA = "RIGHTALT";
          };
        }
      ];
      keymap = [
        {
          name = "Terminal";
          application.only = [ "/org\\.wezfurlong\\.wezterm/" ];
          remap = {
            ALT-c = "C-Shift-c";
            ALT-v = "Shift-Insert";
          };
        }
        {
          name = "Default";
          application.not = [ "/org\\.wezfurlong\\.wezterm/" ];
          remap = {
            Alt-a = "C-a";
            Alt-b = "C-b";
            Alt-c = "C-c";
            Alt-d = "C-d";
            Alt-e = "C-e";
            Alt-f = "C-f";
            Alt-g = "C-g";
            Alt-h = "C-h";
            Alt-i = "C-i";
            Alt-j = "C-j";
            Alt-k = "C-k";
            Alt-l = "C-l";
            Alt-m = "C-m";
            Alt-n = "C-n";
            Alt-o = "C-o";
            Alt-p = "C-p";
            Alt-q = "C-q";
            Alt-r = "C-r";
            Alt-s = "C-s";
            Alt-t = "C-t";
            Alt-u = "C-u";
            Alt-v = "C-v";
            Alt-w = "C-w";
            Alt-x = "C-x";
            Alt-y = "C-y";
            Alt-z = "C-z";
          };
        }
        {
          name = "Emacs Like";
          application.not = [ "/org\\.wezfurlong\\.wezterm/" ];
          remap = {
            C-b = { with_mark = "left"; };
            C-f = { with_mark = "right"; };
            C-p = { with_mark = "up"; };
            C-n = { with_mark = "down"; };
            C-a = { with_mark = "home"; };
            C-e = { with_mark = "end"; };
            C-h = "BackSpace";
            C-d = "Delete";
            C-m = "enter";
            C-j = "enter";
            C-k = [ "Shift-end" "C-x" { set_mark = false; } ];
          };
        }
      ];
    };
  };
}
