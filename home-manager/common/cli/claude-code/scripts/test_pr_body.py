import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("pr-body.sh")
JAPANESE_BODY = "`internal/server` のタイムアウトを30秒にした\n"
JAPANESE_TITLE = "fix(server): タイムアウトを延ばす"
PREFIX_FIX = "先頭に feat: や docs(scope): などのprefixを付けて再実行する"
TITLE_FIX = "prefixの後ろを日本語で書き直して再実行する"
BODY_FIX = "bodyを日本語で書き直して再実行する"


class PrBodyTest(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.gh_log = self.root / "gh.log"
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        gh = bin_dir / "gh"
        gh.write_text(f'#!/usr/bin/env bash\nprintf "%s\\n" "$@" > {self.gh_log}\n')
        gh.chmod(0o755)
        review = self.root / "home/.claude/skills/readable-writing/scripts/review.sh"
        review.parent.mkdir(parents=True)
        review.write_text("#!/usr/bin/env bash\nprintf '[]\\n'\n")
        review.chmod(0o755)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.env = {
            **os.environ,
            "PATH": f"{bin_dir}{os.pathsep}{os.environ['PATH']}",
            "HOME": str(self.root / "home"),
            "TMPDIR": str(self.root),
            "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_AUTHOR_NAME": "t",
            "GIT_AUTHOR_EMAIL": "t@example.invalid",
            "GIT_COMMITTER_NAME": "t",
            "GIT_COMMITTER_EMAIL": "t@example.invalid",
        }
        for args in [
            ["init", "-q", "-b", "topic"],
            ["commit", "-q", "--allow-empty", "-m", "init"],
        ]:
            subprocess.run(["git", *args], cwd=self.repo, env=self.env, check=True)

    def body(self, text: str) -> str:
        path = self.root / "body.md"
        path.write_text(text, encoding="utf-8")
        return str(path)

    def run_script(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(SCRIPT), *args], cwd=self.repo, env=self.env, capture_output=True, text=True
        )

    def gh_args(self) -> list[str]:
        return self.gh_log.read_text(encoding="utf-8").splitlines()

    def test_japanese_title_and_body_create_the_pr(self) -> None:
        result = self.run_script("--title", JAPANESE_TITLE, "--body-file", self.body(JAPANESE_BODY))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.gh_args()[:4], ["pr", "create", "--title", JAPANESE_TITLE])

    def test_english_title_is_rejected(self) -> None:
        result = self.run_script(
            "--title", "fix: extend the timeout", "--body-file", self.body(JAPANESE_BODY)
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn(TITLE_FIX, result.stderr)
        self.assertFalse(self.gh_log.exists())

    def test_prefix_only_title_is_rejected(self) -> None:
        for title in ["feat: ", "docs(skill): "]:
            with self.subTest(title=title):
                result = self.run_script("--title", title, "--body-file", self.body(JAPANESE_BODY))
                self.assertEqual(result.returncode, 1)
                self.assertIn(TITLE_FIX, result.stderr)

    def test_title_without_prefix_is_rejected(self) -> None:
        for title in ["タイムアウトを延ばす", "fix:タイムアウトを延ばす"]:
            with self.subTest(title=title):
                result = self.run_script("--title", title, "--body-file", self.body(JAPANESE_BODY))
                self.assertEqual(result.returncode, 1)
                self.assertIn(PREFIX_FIX, result.stderr)
                self.assertNotIn(TITLE_FIX, result.stderr)

    def test_english_body_is_rejected(self) -> None:
        result = self.run_script(
            "--title", JAPANESE_TITLE, "--body-file", self.body("Extend `internal/server`\n")
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn(BODY_FIX, result.stderr)
        self.assertFalse(self.gh_log.exists())

    def test_title_only_edit_skips_the_body(self) -> None:
        result = self.run_script("--edit", "--title", JAPANESE_TITLE, "12")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.gh_args(), ["pr", "edit", "--title", JAPANESE_TITLE, "12"])

    def test_english_title_edit_is_rejected(self) -> None:
        result = self.run_script("--edit", "--title", "fix: extend the timeout")
        self.assertEqual(result.returncode, 1)
        self.assertIn(TITLE_FIX, result.stderr)

    def test_body_edit_without_title_checks_the_body(self) -> None:
        result = self.run_script("--edit", "--body-file", self.body("Extend the timeout\n"))
        self.assertEqual(result.returncode, 1)
        self.assertIn(BODY_FIX, result.stderr)

    def test_edit_without_title_or_body_is_a_usage_error(self) -> None:
        self.assertEqual(self.run_script("--edit", "12").returncode, 2)


if __name__ == "__main__":
    unittest.main()
