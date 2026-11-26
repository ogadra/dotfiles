import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from block_pr_body import BlockedError, check, gh_commands

MUTATION_BODY = (
    'mutation { updatePullRequest(input: {pullRequestId: "x", body: "b"}) { clientMutationId } }'
)
MUTATION_TITLE = (
    'mutation { updatePullRequest(input: {pullRequestId: "x", title: "t"}) { clientMutationId } }'
)
MUTATION_VARIABLE = (
    "mutation($in: UpdatePullRequestInput!) { updatePullRequest(input: $in) { clientMutationId } }"
)


def verdict(script: str) -> str:
    try:
        for command in gh_commands(script):
            check(command)
    except BlockedError as blocked:
        return "undecidable" if "判定できない" in str(blocked) else "denied"
    return "allowed"


class PrCommandTest(unittest.TestCase):
    def test_pr_create_is_denied(self) -> None:
        self.assertEqual(verdict("gh pr create --title t --body b"), "denied")

    def test_pr_create_inside_control_flow_is_denied(self) -> None:
        self.assertEqual(verdict("if true; then gh pr create; fi"), "denied")
        self.assertEqual(verdict("case $x in a) gh pr create;; esac"), "denied")
        self.assertEqual(verdict("echo $(gh pr create)"), "denied")

    def test_pr_create_behind_wrappers_is_denied(self) -> None:
        self.assertEqual(verdict("X=1 rtk proxy env Y=2 gh pr create"), "denied")

    def test_pr_edit_body_flags_are_denied(self) -> None:
        for flags in ["--body b", "-b b", "--body=b", "-bb", "--body-file f", "-F f"]:
            with self.subTest(flags=flags):
                self.assertEqual(verdict(f"gh pr edit 1 {flags}"), "denied")

    def test_pr_edit_without_body_is_allowed(self) -> None:
        self.assertEqual(verdict("gh pr edit 1 --add-label bug --title t"), "allowed")

    def test_other_gh_commands_are_allowed(self) -> None:
        self.assertEqual(verdict("gh pr view 1 && echo 'gh pr create'"), "allowed")

    def test_unparsable_command_is_undecidable(self) -> None:
        self.assertEqual(verdict("gh pr view 1; echo 'oops"), "undecidable")


class RestApiTest(unittest.TestCase):
    def test_creating_pull_with_body_is_denied(self) -> None:
        self.assertEqual(verdict("gh api repos/o/r/pulls -f title=t -f body=b"), "denied")
        self.assertEqual(verdict("gh api /repos/o/r/pulls --input pr.json"), "denied")

    def test_patching_pull_body_is_denied(self) -> None:
        self.assertEqual(verdict("gh api -X PATCH repos/o/r/pulls/3 -f body=b"), "denied")

    def test_pull_requests_without_body_are_allowed(self) -> None:
        self.assertEqual(verdict("gh api repos/o/r/pulls"), "allowed")
        self.assertEqual(verdict("gh api -X PATCH repos/o/r/pulls/3 -f title=t"), "allowed")
        self.assertEqual(verdict("gh api repos/o/r/pulls/3/comments -f body=b"), "allowed")

    def test_patching_issue_body_depends_on_whether_it_is_a_pr(self) -> None:
        script = "gh api -X PATCH repos/o/r/issues/5 -f body=b"
        for answer, expected in [("true", "denied"), ("false", "allowed"), ("?", "undecidable")]:
            with self.subTest(answer=answer), patch("block_pr_body.gh_output", return_value=answer):
                self.assertEqual(verdict(script), expected)

    def test_patching_issue_body_is_undecidable_when_github_is_unreachable(self) -> None:
        error = subprocess.CalledProcessError(1, "gh")
        with patch("block_pr_body.gh_output", side_effect=error):
            self.assertEqual(verdict("gh api -X PATCH repos/o/r/issues/5 -f body=b"), "undecidable")


class GraphqlTest(unittest.TestCase):
    def test_create_pull_request_mutation_is_denied(self) -> None:
        query = "mutation { createPullRequest(input: {}) { clientMutationId } }"
        self.assertEqual(verdict(f"gh api graphql -f query='{query}'"), "denied")

    def test_body_in_inline_input_is_denied(self) -> None:
        self.assertEqual(verdict(f"gh api graphql -f query='{MUTATION_BODY}'"), "denied")

    def test_update_without_body_is_allowed(self) -> None:
        self.assertEqual(verdict(f"gh api graphql -f query='{MUTATION_TITLE}'"), "allowed")

    def test_queries_are_allowed(self) -> None:
        self.assertEqual(verdict("gh api graphql -f query='{ viewer { login } }'"), "allowed")

    def test_query_from_heredoc_is_read(self) -> None:
        script = f"gh api graphql -F query=@- <<'EOF'\n{MUTATION_BODY}\nEOF"
        self.assertEqual(verdict(script), "denied")

    def test_query_from_tab_stripped_heredoc_is_read(self) -> None:
        script = f"gh api graphql -F query=@- <<-EOF\n\t{MUTATION_TITLE}\n\tEOF"
        self.assertEqual(verdict(script), "allowed")

    def test_body_in_variable_is_denied(self) -> None:
        script = f"gh api graphql -f query='{MUTATION_VARIABLE}' -F 'in[body]=b'"
        self.assertEqual(verdict(script), "denied")

    def test_variable_without_body_is_allowed(self) -> None:
        script = f"gh api graphql -f query='{MUTATION_VARIABLE}' -f 'in[title]=t'"
        self.assertEqual(verdict(script), "allowed")

    def test_missing_variable_is_undecidable(self) -> None:
        self.assertEqual(verdict(f"gh api graphql -f query='{MUTATION_VARIABLE}'"), "undecidable")

    def test_input_file_is_read(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            request = Path(directory) / "request.json"
            request.write_text(
                '{"query": "' + MUTATION_VARIABLE + '", "variables": {"in": {"body": "b"}}}',
                encoding="utf-8",
            )
            self.assertEqual(verdict(f"gh api graphql --input {request}"), "denied")

    def test_input_from_pipe_is_undecidable(self) -> None:
        self.assertEqual(verdict("cat request.json | gh api graphql --input -"), "undecidable")

    def test_query_from_expansion_is_undecidable(self) -> None:
        self.assertEqual(verdict('gh api graphql -f query="$QUERY"'), "undecidable")

    def test_fragment_in_mutation_is_undecidable(self) -> None:
        query = (
            "mutation { ...F } fragment F on Mutation { createPullRequest { clientMutationId } }"
        )
        self.assertEqual(verdict(f"gh api graphql -f query='{query}'"), "undecidable")

    def test_broken_query_is_undecidable(self) -> None:
        self.assertEqual(verdict("gh api graphql -f query='mutation {'"), "undecidable")


if __name__ == "__main__":
    unittest.main()
