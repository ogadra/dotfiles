{ ... }:
{
  # Distrusts the roots chaining the eMudhra intermediates whose private keys leaked in Oct 2026; remove once cacert ships NSS >= 3.131.1
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
