{ ... }:
{
  # Distrusts the root chaining the eMudhra intermediates whose private keys leaked in Oct 2026; NSS 3.131.1 still ships it, and cacert fails on names it no longer has
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];
}
