{ lib, ... }:
let
  version = "15.9.0";
  dmgUrl = "https://github.com/pqrs-org/Karabiner-Elements/releases/download/v${version}/Karabiner-Elements-${version}.dmg";
  dmgSha256 = "c495f131165a4deefbe32e4a8ff5b3ffb000fcd5507140344899b8fee31574ee";
  emacsLikeExcludedApps = [
    "^com\\.microsoft\\.VSCode$"
    "^com\\.github\\.wez\\.wezterm$"
  ];

  unlessEmacsLike = {
    type = "frontmost_application_unless";
    bundle_identifiers = emacsLikeExcludedApps;
  };

  mkEmacsLike = from: to: {
    type = "basic";
    conditions = [ unlessEmacsLike ];
    from = from;
    to = [ to ];
  };

  karabinerConfig = {
    global = {
      check_for_updates_on_startup = false;
      unsafe_ui = true;
    };
    profiles = [
      {
        name = "Default profile";
        selected = true;
        parameters = { delay_milliseconds_before_open_device = 0; };
        virtual_hid_keyboard = {
          country_code = 0;
          keyboard_type_v2 = "ansi";
        };

        fn_function_keys = [
          { from.key_code = "f3"; to = [{ key_code = "mission_control"; }]; }
          { from.key_code = "f4"; to = [{ key_code = "launchpad"; }]; }
          { from.key_code = "f5"; to = [{ key_code = "illumination_decrement"; }]; }
          { from.key_code = "f6"; to = [{ key_code = "illumination_increment"; }]; }
        ];

        devices = [
          # Apple Internal Keyboard
          {
            identifiers = {
              is_keyboard = true;
              product_id = 638;
              vendor_id = 1452;
            };
            simple_modifications = [
              { from.key_code = "caps_lock";    to = [{ key_code = "left_control"; }]; }
              { from.key_code = "left_command"; to = [{ key_code = "left_option"; }]; }
              { from.key_code = "left_control"; to = [{ key_code = "caps_lock"; }]; }
              { from.key_code = "left_option";  to = [{ key_code = "left_command"; }]; }
            ];
          }
          # Default (all other keyboards): swap caps_lock <-> left_control
          {
            identifiers.is_keyboard = true;
            simple_modifications = [
              { from.key_code = "caps_lock";    to = [{ key_code = "left_control"; }]; }
              { from.key_code = "left_control"; to = [{ key_code = "caps_lock"; }]; }
            ];
          }
        ];

        complex_modifications.rules = [
          {
            description = "New Rule for HHKB";
            manipulators = [
              { type = "basic"; from = { key_code = "1"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "f1"; }]; }
              { type = "basic"; from = { key_code = "2"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "f2"; }]; }
              { type = "basic"; from = { key_code = "3"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "f3"; }]; }
              { type = "basic"; from = { key_code = "4"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "f4"; }]; }
              { type = "basic"; from = { key_code = "5"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "f5"; }]; }
              { type = "basic"; from = { key_code = "tab"; modifiers = { mandatory = [ "right_option" ]; optional = [ "caps_lock" ]; }; }; to = [{ key_code = "caps_lock"; }]; }
            ];
          }
          {
            description = "Emacs Like key bindings";
            manipulators = [
              (mkEmacsLike
                { key_code = "d"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "option" ]; }; }
                { key_code = "delete_forward"; })
              (mkEmacsLike
                { key_code = "h"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "option" ]; }; }
                { key_code = "delete_or_backspace"; })
              (mkEmacsLike
                { key_code = "m"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "shift" "option" ]; }; }
                { key_code = "return_or_enter"; })
              (mkEmacsLike
                { key_code = "b"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "shift" "option" ]; }; }
                { key_code = "left_arrow"; })
              (mkEmacsLike
                { key_code = "f"; modifiers.mandatory = [ "control" ]; }
                { key_code = "right_arrow"; })
              (mkEmacsLike
                { key_code = "n"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "shift" "option" ]; }; }
                { key_code = "down_arrow"; })
              (mkEmacsLike
                { key_code = "p"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "shift" "option" ]; }; }
                { key_code = "up_arrow"; })
              (mkEmacsLike
                { key_code = "v"; modifiers = { mandatory = [ "control" ]; optional = [ "caps_lock" "shift" ]; }; }
                { key_code = "page_down"; })
            ];
          }
        ];
      }
    ];
  };
in
{
  home.file.".config/karabiner/karabiner.json" = {
    text = builtins.toJSON karabinerConfig;
  };

  home.activation.installKarabinerElements = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/Karabiner-Elements.app" ]; then
      _dmg=$(mktemp /tmp/karabiner-XXXXXX.dmg)
      echo "Downloading Karabiner-Elements ${version}..."
      /usr/bin/curl -L -o "$_dmg" "${dmgUrl}"
      echo "${dmgSha256}  $_dmg" | /usr/bin/shasum -a 256 -c - || { echo "SHA256 mismatch!"; rm -f "$_dmg"; exit 1; }
      _mnt=$(/usr/bin/mktemp -d /tmp/karabiner-mnt-XXXXXX)
      /usr/bin/hdiutil attach "$_dmg" -mountpoint "$_mnt" -quiet
      /usr/bin/sudo /usr/sbin/installer -pkg "$_mnt/Karabiner-Elements.pkg" -target /
      /usr/bin/hdiutil detach "$_mnt" -quiet
      rm -f "$_dmg"
    fi
  '';
}
