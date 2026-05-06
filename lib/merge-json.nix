{ lib, pkgs }:
path: nixValues:
let
  json = lib.escapeShellArg (builtins.toJSON nixValues);
  jq = "${pkgs.jq}/bin/jq";
in ''
  (
    _file="${path}"
    _nix=${json}
    mkdir -p "$(dirname "$_file")"
    if [ -f "$_file" ] && ! [ -L "$_file" ]; then
      ${jq} -s '.[0] * .[1]' "$_file" - <<< "$_nix" > "$_file.tmp" && mv "$_file.tmp" "$_file"
    else
      rm -f "$_file"
      printf '%s' "$_nix" > "$_file"
    fi
  )
''
