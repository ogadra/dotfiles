#!/usr/bin/env python3

import sys
from pathlib import Path

from lib.systems import supported_systems, unsupported


def main() -> None:
    supported = supported_systems(Path("flake.nix").read_text(encoding="utf-8"))
    findings = [
        finding
        for path in sys.argv[1:]
        for finding in unsupported(path, Path(path).read_text(encoding="utf-8"), supported)
    ]
    for finding in findings:
        print(
            f"{finding.path}:{finding.line}: {finding.text} is {finding.system},"
            " which is not in flake.nix supportedSystems",
            file=sys.stderr,
        )
    if findings:
        sys.exit(1)


if __name__ == "__main__":
    main()
