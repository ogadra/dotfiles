import json
import os
import subprocess
from typing import Any

from .commands import capture
from .errors import CommandError

REPO = os.environ["REPO"]


def gh_get(path: str) -> Any:
    return json.loads(capture("gh", "api", f"repos/{REPO}/{path}"))


def gh_send(method: str, path: str, body: dict[str, Any]) -> Any:
    result = subprocess.run(
        ["gh", "api", "-X", method, f"repos/{REPO}/{path}", "--input", "-"],
        input=json.dumps(body).encode(),
        stdout=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        raise CommandError(("gh", "api", "-X", method, path))
    return json.loads(result.stdout)
