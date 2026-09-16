from .refused import RefusedError


class CommandError(RefusedError):
    def __init__(self, command: tuple[str, ...]) -> None:
        super().__init__("command failed: " + " ".join(command))
        self.command = command
