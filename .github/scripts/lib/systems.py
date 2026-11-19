import re
from dataclasses import dataclass

SUPPORTED_SYSTEMS = re.compile(r"supportedSystems\s*=\s*\[(?P<body>[^\]]*)\]")
QUOTED = re.compile(r'"([^"]+)"')
SYSTEM = re.compile(
    r"\b(?P<arch>aarch64|x86_64|i686|armv6l|armv7l|riscv64|powerpc64le|loongarch64)"
    r"(?:-[a-z0-9_]+)?-(?P<kernel>linux|darwin)\b"
)


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    text: str
    system: str


def supported_systems(flake: str) -> set[str]:
    match = SUPPORTED_SYSTEMS.search(flake)
    if match is None:
        raise ValueError("flake.nix has no supportedSystems list")
    return set(QUOTED.findall(match["body"]))


def unsupported(path: str, source: str, supported: set[str]) -> list[Finding]:
    findings: list[Finding] = []
    for number, line in enumerate(source.splitlines(), start=1):
        for match in SYSTEM.finditer(line):
            system = f"{match['arch']}-{match['kernel']}"
            if system not in supported:
                findings.append(Finding(path, number, match[0], system))
    return findings
