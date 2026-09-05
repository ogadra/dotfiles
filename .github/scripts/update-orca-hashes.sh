#!/usr/bin/env bash
# Recompute the Orca download hashes for the version pinned in the Nix module.
# Renovate bumps the version string; the hashes have to follow it here.
set -euo pipefail

nix_file="home-manager/common/apps/orca/default.nix"

sha256_hex() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

hex_to_base64() {
  printf '%b' "$(printf '%s' "$1" | sed 's/../\\x&/g')" | base64 | tr -d '\n'
}

version=$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$nix_file")
if [ -z "$version" ]; then
  echo "no version pinned in $nix_file" >&2
  exit 1
fi
release_url="https://github.com/stablyai/orca/releases/download/v${version}"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

curl -fsSL -o "$work_dir/orca-linux.AppImage" "${release_url}/orca-linux.AppImage"
curl -fsSL -o "$work_dir/orca-macos-arm64.dmg" "${release_url}/orca-macos-arm64.dmg"

app_image_hash="sha256-$(hex_to_base64 "$(sha256_hex "$work_dir/orca-linux.AppImage")")"
dmg_sha256=$(sha256_hex "$work_dir/orca-macos-arm64.dmg")

sed \
  -e "s|hash = \"sha256-[^\"]*\";|hash = \"${app_image_hash}\";|" \
  -e "s|dmgSha256 = \"[^\"]*\";|dmgSha256 = \"${dmg_sha256}\";|" \
  "$nix_file" > "$work_dir/default.nix"
mv "$work_dir/default.nix" "$nix_file"
