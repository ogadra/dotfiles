import json
import re
from pathlib import Path
from typing import Any

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


def last_modified(node: dict[str, Any]) -> int | None:
    stamp: int | None = node.get("locked", {}).get("lastModified")
    return stamp


def check_lock(main_lock: bytes | str, branch_lock: bytes | str) -> None:
    on_main: dict[str, Any] = json.loads(main_lock)["nodes"]
    on_branch: dict[str, Any] = json.loads(branch_lock)["nodes"]

    def parents(name: str) -> list[str]:
        # A list value is a follows path, not an edge, so only string values name a child node.
        return [
            parent for parent, node in on_main.items() if name in node.get("inputs", {}).values()
        ]

    def moved_forward(name: str, seen: frozenset[str]) -> bool:
        if name in seen:
            return False
        main_stamp = last_modified(on_main[name])
        if main_stamp is None:
            return False
        if name not in on_branch:
            return dropped_by_newer_parent(name, seen)
        branch_stamp = last_modified(on_branch[name])
        return branch_stamp is not None and branch_stamp > main_stamp

    def dropped_by_newer_parent(name: str, seen: frozenset[str]) -> bool:
        # A node can vanish only because an upstream release stopped depending on it.
        found = parents(name)
        return bool(found) and all(moved_forward(parent, seen | {name}) for parent in found)

    older = []
    for name, node in on_main.items():
        stamp = last_modified(node)
        if stamp is None:
            continue
        if name in on_branch:
            if (last_modified(on_branch[name]) or 0) < stamp:
                older.append(name)
        elif not dropped_by_newer_parent(name, frozenset()):
            older.append(name)
    if older:
        raise LockRegressionError(sorted(older))


def verify_lock() -> None:
    check_lock(
        capture("git", "show", "origin/main:flake.lock"),
        Path("flake.lock").read_text(encoding="utf-8"),
    )


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
