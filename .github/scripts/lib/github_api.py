import json
import os
import subprocess
from typing import Any

from .commands import capture
from .errors import CommandError

REPO = os.environ["REPO"]


def gh_input(arguments: list[str], body: dict[str, Any]) -> Any:
    result = subprocess.run(
        ["gh", "api", *arguments, "--input", "-"],
        input=json.dumps(body).encode(),
        stdout=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        raise CommandError(("gh", "api", *arguments))
    return json.loads(result.stdout)


def gh_get(path: str) -> Any:
    return json.loads(capture("gh", "api", f"repos/{REPO}/{path}"))


def gh_send(method: str, path: str, body: dict[str, Any]) -> Any:
    return gh_input(["-X", method, f"repos/{REPO}/{path}"], body)


def gh_graphql(query: str, variables: dict[str, Any]) -> Any:
    return gh_input(["graphql"], {"query": query, "variables": variables})


def gh_drop(path: str) -> None:
    subprocess.run(
        ["gh", "api", "-X", "DELETE", f"repos/{REPO}/{path}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
