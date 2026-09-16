from .refused import RefusedError


class ConflictError(RefusedError):
    def __init__(self, path: str) -> None:
        super().__init__(f"{path}: conflict hunk carries no version to compare")
        self.path = path
