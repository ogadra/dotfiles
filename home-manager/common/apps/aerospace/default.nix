{ lib, ... }:
let
  # Only Beta builds are published; the app is signed with the author's own certificate and not notarized
  version = "0.21.3-Beta";
  zipUrl = "https://github.com/nikitabobko/AeroSpace/releases/download/v${version}/AeroSpace-v${version}.zip";
  zipSha256 = "bdbd3fedb3a41bdd3987d241dd5cc1d8b74a56fdbc0d76a98e6925c5cfef4ce4";
in
{
  # Follows the upstream default-config.toml; bindings that herdr already claims (alt+letters, alt+tab, alt+shift+tab) are left out
  xdg.configFile."aerospace/aerospace.toml".text = ''
    config-version = 2

    after-startup-command = []
    start-at-login = true

    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    accordion-padding = 30
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    automatically-unhide-macos-hidden-apps = false

    persistent-workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

    key-mapping.preset = 'qwerty'

    gaps.inner.horizontal = 0
    gaps.inner.vertical = 0
    gaps.outer.left = 0
    gaps.outer.bottom = 0
    gaps.outer.top = 0
    gaps.outer.right = 0

    [mode.main.binding]
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'

    # Upstream uses alt-h/j/k/l, which herdr takes for switching tabs
    alt-left = 'focus left'
    alt-down = 'focus down'
    alt-up = 'focus up'
    alt-right = 'focus right'

    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    alt-minus = 'resize smart -50'
    alt-equal = 'resize smart +50'

    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    f = ['layout floating tiling', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']
    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']
  '';

  home.activation.installAeroSpace = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "/Applications/AeroSpace.app" ]; then
      _zip=$(mktemp /tmp/aerospace-XXXXXX.zip)
      /usr/bin/curl -L -o "$_zip" "${zipUrl}"
      echo "${zipSha256}  $_zip" | /usr/bin/shasum -a 256 -c - || { rm -f "$_zip"; exit 1; }
      _dir=$(/usr/bin/mktemp -d /tmp/aerospace-dir-XXXXXX)
      /usr/bin/unzip -q "$_zip" -d "$_dir"
      /bin/cp -R "$_dir/AeroSpace-v${version}/AeroSpace.app" /Applications/
      /usr/bin/xattr -dr com.apple.quarantine /Applications/AeroSpace.app
      rm -rf "$_zip" "$_dir"
    fi
  '';
}
