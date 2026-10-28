{ ... }:
{
  # Distrusts the root cross-signing the leaked eMudhra intermediates, which NSS 3.131.1 still ships: https://emudhra.we-have-a-problem.com/#linux
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];
}
