from .refused import RefusedError


class UnsupportedModeError(RefusedError):
    def __init__(self, path: str, mode: str) -> None:
        super().__init__(f"{path}: mode {mode} does not survive the commit API")
        self.path = path
        self.mode = mode
