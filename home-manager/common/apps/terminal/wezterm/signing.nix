{ lib, pkgs, ... }:
let
  identity = "Local Codesign";
  keychain = "$HOME/Library/Keychains/login.keychain-db";

  certRequest = pkgs.writeText "local-codesign-req.cnf" ''
    [req]
    distinguished_name = dn
    x509_extensions = v3
    prompt = no

    [dn]
    CN = ${identity}

    [v3]
    basicConstraints = critical,CA:false
    keyUsage = critical,digitalSignature
    extendedKeyUsage = critical,codeSigning
  '';

  weztermWithoutApp = pkgs.symlinkJoin {
    name = "wezterm-without-app";
    paths = [ pkgs.wezterm ];
    postBuild = ''
      rm -rf $out/Applications
    '';
  };
in
lib.mkIf (!pkgs.stdenv.hostPlatform.isLinux) {
  programs.wezterm.package = weztermWithoutApp;

  home.activation.createLocalCodesignCert = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if ! /usr/bin/security find-certificate -c "${identity}" "${keychain}" > /dev/null 2>&1; then
      _work=$(/usr/bin/mktemp -d /tmp/local-codesign-XXXXXX)
      _pass=$(/usr/bin/openssl rand -hex 16)
      /usr/bin/openssl req -newkey rsa:2048 -nodes -keyout "$_work/key.pem" \
        -x509 -days 7300 -out "$_work/cert.pem" -config ${certRequest}
      /usr/bin/openssl pkcs12 -export -inkey "$_work/key.pem" -in "$_work/cert.pem" \
        -name "${identity}" -out "$_work/cert.p12" -passout "pass:$_pass"
      /usr/bin/security import "$_work/cert.p12" -k "${keychain}" -P "$_pass" -A -T /usr/bin/codesign
      /usr/bin/security add-trusted-cert -r trustRoot -p codeSign -k "${keychain}" "$_work/cert.pem"
      /bin/rm -rf "$_work"
    fi
  '';

  home.activation.signWezTerm = lib.hm.dag.entryAfter [ "createLocalCodesignCert" ] ''
    _app="$HOME/Applications/WezTerm.app"
    _stamp="$HOME/Applications/.wezterm-signed-source"
    if [ "$(/bin/cat "$_stamp" 2>/dev/null)" != "${pkgs.wezterm}" ]; then
      /bin/mkdir -p "$HOME/Applications"
      /bin/rm -rf "$_app"
      /bin/cp -R "${pkgs.wezterm}/Applications/WezTerm.app" "$_app"
      /bin/chmod -R u+w "$_app"
      /usr/bin/codesign --force --deep --sign "${identity}" "$_app"
      echo "${pkgs.wezterm}" > "$_stamp"
    fi
  '';
}
