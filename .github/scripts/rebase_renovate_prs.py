#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Any

from lib.commands import capture, try_run
from lib.errors import RefusedError
from lib.rebase import rebase_onto_main
from lib.signing import is_signed, push_signed


def main() -> None:
    os.environ["GIT_COMMITTER_NAME"] = "renovate-ogadra[bot]"
    os.environ["GIT_COMMITTER_EMAIL"] = "313657277+renovate-ogadra[bot]@users.noreply.github.com"

    listing = capture(
        "gh",
        "pr",
        "list",
        "--state",
        "open",
        "--limit",
        "100",
        "--json",
        "number,headRefName,headRefOid",
    )
    pull_requests: list[dict[str, Any]] = json.loads(listing)

    signed: list[int] = []
    skipped: list[int] = []
    for pull_request in pull_requests:
        branch = pull_request["headRefName"]
        if not branch.startswith("renovate/"):
            continue
        try:
            capture("git", "fetch", "--quiet", "origin", branch)
            merged = try_run(
                "git", "merge-base", "--is-ancestor", "origin/main", f"origin/{branch}"
            )
            if merged and is_signed(pull_request["headRefOid"]):
                continue
            capture("git", "checkout", "--quiet", "-B", branch, f"origin/{branch}")
            rebase_onto_main()
            push_signed(branch)
        except RefusedError as refusal:
            print(f"#{pull_request['number']} left alone: {refusal}", file=sys.stderr)
            subprocess.run(["git", "rebase", "--abort"], stderr=subprocess.DEVNULL, check=False)
            skipped.append(pull_request["number"])
        else:
            signed.append(pull_request["number"])

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with Path(summary).open("a", encoding="utf-8") as handle:
            handle.write(
                "Signed:{}\nLeft alone:{}\n".format(
                    "".join(f" #{number}" for number in signed) or " none",
                    "".join(f" #{number}" for number in skipped) or " none",
                )
            )


if __name__ == "__main__":
    main()
