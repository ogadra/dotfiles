import json
import re
from pathlib import Path

from .commands import capture, capture_text, exit_code, try_run
from .errors import CommandError, ConflictError, LockRegressionError, RebaseStalledError

HUNK = re.compile(r"<<<<<<< [^\n]*\n(.*?)\n=======\n(.*?)>>>>>>> [^\n]*\n", re.S)
MERGE_TREE = ("git", "merge-tree", "--write-tree", "origin/main")


def conflicts_with_main(branch: str) -> bool:
    code = exit_code(*MERGE_TREE, branch)
    if code > 1:
        raise CommandError((*MERGE_TREE, branch))
    return code == 1


def version(side: str) -> tuple[int, ...] | None:
    found = re.findall(r"\d+(?:\.\d+)+", side)
    return tuple(int(part) for part in found[-1].split(".")) if found else None


def keep_newer_version(path: str) -> None:
    def keep_newer(match: re.Match[str]) -> str:
        ours, theirs = match.group(1), match.group(2)
        ours_version, theirs_version = version(ours), version(theirs)
        if ours_version is None or theirs_version is None:
            raise ConflictError(path)
        return theirs if theirs_version >= ours_version else ours + "\n"

    file = Path(path)
    file.write_text(HUNK.sub(keep_newer, file.read_text(encoding="utf-8")), encoding="utf-8")


def stamps(content: bytes | str) -> dict[str, int]:
    nodes = json.loads(content)["nodes"]
    return {
        name: node["locked"]["lastModified"]
        for name, node in nodes.items()
        if "lastModified" in node.get("locked", {})
    }


def verify_lock() -> None:
    on_main = stamps(capture("git", "show", "origin/main:flake.lock"))
    on_branch = stamps(Path("flake.lock").read_text(encoding="utf-8"))
    older = sorted(name for name, stamp in on_main.items() if on_branch.get(name, 0) < stamp)
    if older:
        raise LockRegressionError(older)


def resolve(path: str) -> None:
    if path == "flake.lock":
        capture("git", "checkout", "--theirs", "--", "flake.lock")
        verify_lock()
    else:
        keep_newer_version(path)


def conflicts() -> list[str]:
    return capture_text("git", "diff", "--name-only", "--diff-filter=U").splitlines()


def rebase_onto_main() -> None:
    if try_run("git", "rebase", "origin/main"):
        return
    while True:
        files = conflicts()
        if not files:
            raise RebaseStalledError("stopped with nothing to resolve")
        for path in files:
            resolve(path)
            capture("git", "add", path)
        if try_run("git", "-c", "core.editor=true", "rebase", "--continue"):
            return
        if not conflicts():
            raise RebaseStalledError("did not advance")
