from .refused import RefusedError


class RebaseStalledError(RefusedError):
    def __init__(self, reason: str) -> None:
        super().__init__(f"rebase {reason}")
        self.reason = reason
