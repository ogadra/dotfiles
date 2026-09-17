from .refused import RefusedError


class BranchMovedError(RefusedError):
    def __init__(self, branch: str) -> None:
        super().__init__(f"{branch} moved while it was being rebased")
        self.branch = branch
