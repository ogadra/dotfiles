import base64
from collections.abc import Iterator

from .commands import capture, capture_text
from .errors import BranchMovedError, UnsupportedModeError
from .github_api import REPO, gh_drop, gh_get, gh_graphql, gh_send

COMMIT = """
mutation ($input: CreateCommitOnBranchInput!) {
  createCommitOnBranch(input: $input) {
    commit {
      oid
    }
  }
}
"""


def changed_paths(commit: str) -> Iterator[tuple[str, str]]:
    listing = capture("git", "diff-tree", "--no-commit-id", "--name-status", "-r", "-z", commit)
    fields = listing.decode().split("\0")[:-1]
    return zip(fields[::2], fields[1::2], strict=True)


def file_changes(commit: str) -> dict[str, list[dict[str, str]]]:
    additions: list[dict[str, str]] = []
    deletions: list[dict[str, str]] = []
    for status, path in changed_paths(commit):
        if status == "D":
            deletions.append({"path": path})
            continue
        mode = capture_text("git", "ls-tree", commit, "--", path).split()[0]
        if mode != "100644":
            raise UnsupportedModeError(path, mode)
        blob = capture("git", "cat-file", "blob", f"{commit}:{path}")
        additions.append({"path": path, "contents": base64.b64encode(blob).decode()})
    return {"additions": additions, "deletions": deletions}


def commit_on_branch(branch: str, parent: str, commit: str) -> str:
    message = capture_text("git", "log", "-1", "--format=%B", commit).strip("\n")
    headline, _, body = message.partition("\n")
    response = gh_graphql(
        COMMIT,
        {
            "input": {
                "branch": {"repositoryNameWithOwner": REPO, "branchName": branch},
                "expectedHeadOid": parent,
                "message": {"headline": headline, "body": body.strip("\n")},
                "fileChanges": file_changes(commit),
            }
        },
    )
    oid: str = response["data"]["createCommitOnBranch"]["commit"]["oid"]
    return oid


def is_signed(commit: str) -> bool:
    verified: bool = gh_get(f"commits/{commit}")["commit"]["verification"]["verified"]
    return verified


def push_signed(branch: str) -> None:
    head = capture_text("git", "rev-parse", f"origin/{branch}").strip()
    if gh_get(f"git/refs/heads/{branch}")["object"]["sha"] != head:
        raise BranchMovedError(branch)

    staging = f"signing/{branch}"
    parent = capture_text("git", "rev-parse", "origin/main").strip()
    gh_drop(f"git/refs/heads/{staging}")
    gh_send("POST", "git/refs", {"ref": f"refs/heads/{staging}", "sha": parent})
    try:
        for commit in capture_text("git", "rev-list", "--reverse", "origin/main..HEAD").split():
            parent = commit_on_branch(staging, parent, commit)
        gh_send("PATCH", f"git/refs/heads/{branch}", {"sha": parent, "force": True})
    finally:
        gh_drop(f"git/refs/heads/{staging}")
