import unittest

from lib.systems import Finding, supported_systems, unsupported

FLAKE = """
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
"""
SUPPORTED = {"x86_64-linux", "aarch64-darwin"}


class SupportedSystemsTest(unittest.TestCase):
    def test_reads_the_list_from_the_flake(self) -> None:
        self.assertEqual(supported_systems(FLAKE), SUPPORTED)

    def test_rejects_a_flake_without_the_list(self) -> None:
        with self.assertRaises(ValueError):
            supported_systems("{ }")


class UnsupportedTest(unittest.TestCase):
    def test_accepts_supported_nix_systems(self) -> None:
        self.assertEqual(unsupported("a.nix", 'x86_64-linux = "aarch64-darwin";', SUPPORTED), [])

    def test_accepts_vendor_triples_of_supported_systems(self) -> None:
        source = 'url = "devin-x86_64-unknown-linux.tar.gz"; target = "aarch64-apple-darwin";'
        self.assertEqual(unsupported("a.nix", source, SUPPORTED), [])

    def test_reports_an_unsupported_nix_system(self) -> None:
        source = "{\n  aarch64-linux = { };\n}"
        self.assertEqual(
            unsupported("a.nix", source, SUPPORTED),
            [Finding("a.nix", 2, "aarch64-linux", "aarch64-linux")],
        )

    def test_reports_a_vendor_triple_of_an_unsupported_system(self) -> None:
        source = 'target = "aarch64-unknown-linux";'
        self.assertEqual(
            unsupported("a.nix", source, SUPPORTED),
            [Finding("a.nix", 1, "aarch64-unknown-linux", "aarch64-linux")],
        )


if __name__ == "__main__":
    unittest.main()
