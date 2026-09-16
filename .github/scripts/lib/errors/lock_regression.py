from .refused import RefusedError


class LockRegressionError(RefusedError):
    def __init__(self, inputs: list[str]) -> None:
        super().__init__("flake.lock would move these inputs backwards: " + ", ".join(inputs))
        self.inputs = inputs
