import json
import unittest
from typing import Any

from lib.errors import LockRegressionError
from lib.rebase import check_lock


def node(stamp: int, **inputs: str) -> dict[str, Any]:
    return {"inputs": inputs, "locked": {"lastModified": stamp}}


def lock(**nodes: dict[str, Any]) -> str:
    root = {"inputs": {"nixpkgs": "nixpkgs", "wezterm": "wezterm"}}
    return json.dumps({"nodes": {"root": root, **nodes}, "root": "root", "version": 7})


MAIN = lock(
    nixpkgs=node(100),
    wezterm=node(100, **{"flake-utils": "flake-utils"}),
    **{"flake-utils": node(50, systems="systems_2"), "systems_2": node(40)},
)


class CheckLockTest(unittest.TestCase):
    def test_accepts_inputs_dropped_by_a_newer_parent(self) -> None:
        check_lock(MAIN, lock(nixpkgs=node(100), wezterm=node(200)))

    def test_rejects_inputs_dropped_while_the_parent_stays(self) -> None:
        with self.assertRaises(LockRegressionError) as raised:
            check_lock(MAIN, lock(nixpkgs=node(100), wezterm=node(100)))
        self.assertEqual(raised.exception.inputs, ["flake-utils", "systems_2"])

    def test_rejects_a_kept_input_that_moves_backwards(self) -> None:
        branch = lock(
            nixpkgs=node(100),
            wezterm=node(200, **{"flake-utils": "flake-utils"}),
            **{"flake-utils": node(30, systems="systems_2"), "systems_2": node(40)},
        )
        with self.assertRaises(LockRegressionError) as raised:
            check_lock(MAIN, branch)
        self.assertEqual(raised.exception.inputs, ["flake-utils"])

    def test_rejects_a_dropped_root_input(self) -> None:
        branch = lock(
            wezterm=node(100, **{"flake-utils": "flake-utils"}),
            **{"flake-utils": node(50, systems="systems_2"), "systems_2": node(40)},
        )
        with self.assertRaises(LockRegressionError) as raised:
            check_lock(MAIN, branch)
        self.assertEqual(raised.exception.inputs, ["nixpkgs"])


if __name__ == "__main__":
    unittest.main()
