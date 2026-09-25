#!/usr/bin/env python3

import json
import os
import re
from collections import defaultdict
from pathlib import Path
from typing import Any

from lib.commands import capture

DATE_PREFIX = re.compile(r"^\d{4}-\d{2}-\d{2}-")
VERSION_SUFFIX = re.compile(r"-v?\d+(?:\.\d+)*$")
FIELDS = "number,headRefName,createdAt,isDraft,mergeable,statusCheckRollup,state"


def update_key(branch: str) -> str:
    topic = branch.removeprefix("renovate/")
    return DATE_PREFIX.sub("", VERSION_SUFFIX.sub("", topic))


def outcome(check: dict[str, Any]) -> str:
    state: str = check["conclusion"] if check["__typename"] == "CheckRun" else check["state"]
    return state


def is_ready(pull_request: dict[str, Any]) -> bool:
    # An update already on main beats anything a check could say about it.
    if pull_request["state"] == "MERGED":
        return True
    checks: list[dict[str, Any]] = pull_request["statusCheckRollup"]
    return (
        not pull_request["isDraft"]
        and pull_request["mergeable"] == "MERGEABLE"
        and bool(checks)
        and all(outcome(check) == "SUCCESS" for check in checks)
    )


def newest_ready(group: list[dict[str, Any]]) -> dict[str, Any] | None:
    return next((pull_request for pull_request in reversed(group) if is_ready(pull_request)), None)


def close(pull_request: dict[str, Any], winner: dict[str, Any]) -> None:
    capture(
        "gh",
        "pr",
        "close",
        str(pull_request["number"]),
        "--comment",
        f"Superseded by #{winner['number']}.",
        "--delete-branch",
    )


def listed(state: str) -> list[dict[str, Any]]:
    listing = capture("gh", "pr", "list", "--state", state, "--limit", "100", "--json", FIELDS)
    pull_requests: list[dict[str, Any]] = json.loads(listing)
    return pull_requests


def main() -> None:
    groups: defaultdict[str, list[dict[str, Any]]] = defaultdict(list)
    for pull_request in listed("open") + listed("merged"):
        branch = pull_request["headRefName"]
        if branch.startswith("renovate/"):
            groups[update_key(branch)].append(pull_request)

    closed: list[int] = []
    for group in groups.values():
        group.sort(key=lambda pull_request: pull_request["createdAt"])
        winner = newest_ready(group)
        if winner is None:
            continue
        for pull_request in group:
            if pull_request is winner:
                break
            if pull_request["state"] != "OPEN":
                continue
            close(pull_request, winner)
            closed.append(pull_request["number"])

    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with Path(summary).open("a", encoding="utf-8") as handle:
            handle.write(
                "Closed:{}\n".format("".join(f" #{number}" for number in closed) or " none")
            )


if __name__ == "__main__":
    main()
