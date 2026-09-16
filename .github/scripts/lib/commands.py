import subprocess

from .errors import CommandError


def capture(*command: str) -> bytes:
    result = subprocess.run(command, stdout=subprocess.PIPE, check=False)
    if result.returncode:
        raise CommandError(command)
    return result.stdout


def capture_text(*command: str) -> str:
    return capture(*command).decode()


def try_run(*command: str) -> bool:
    return subprocess.run(command, check=False).returncode == 0
