import base64
from collections.abc import Iterator
from typing import Any

from .commands import capture, capture_text
from .errors import BranchMovedError
from .github_api import gh_get, gh_send


def changed_paths(commit: str) -> Iterator[tuple[str, str]]:
    listing = capture("git", "diff-tree", "--no-commit-id", "--name-status", "-r", "-z", commit)
    fields = listing.decode().split("\0")[:-1]
    return zip(fields[::2], fields[1::2], strict=True)


def push_signed(branch: str) -> None:
    parent = capture_text("git", "rev-parse", "origin/main").strip()
    tree = capture_text("git", "rev-parse", "origin/main^{tree}").strip()

    for commit in capture_text("git", "rev-list", "--reverse", "origin/main..HEAD").split():
        entries: list[dict[str, Any]] = []
        for status, path in changed_paths(commit):
            if status == "D":
                entries.append({"path": path, "mode": "100644", "type": "blob", "sha": None})
                continue
            content = base64.b64encode(capture("git", "cat-file", "blob", f"{commit}:{path}"))
            blob = gh_send("POST", "git/blobs", {"content": content.decode(), "encoding": "base64"})
            mode = capture_text("git", "ls-tree", commit, "--", path).split()[0]
            entries.append({"path": path, "mode": mode, "type": "blob", "sha": blob["sha"]})

        tree = gh_send("POST", "git/trees", {"base_tree": tree, "tree": entries})["sha"]
        identity = capture_text("git", "log", "-1", "--format=%an%n%ae%n%aI", commit)
        name, email, date = identity.splitlines()
        message = capture_text("git", "log", "-1", "--format=%B", commit).rstrip("\n")
        author = {"name": name, "email": email, "date": date}
        body = {"message": message, "tree": tree, "parents": [parent], "author": author}
        parent = gh_send("POST", "git/commits", body)["sha"]

    head = capture_text("git", "rev-parse", f"origin/{branch}").strip()
    if gh_get(f"git/refs/heads/{branch}")["object"]["sha"] != head:
        raise BranchMovedError(branch)
    gh_send("PATCH", f"git/refs/heads/{branch}", {"sha": parent, "force": True})
