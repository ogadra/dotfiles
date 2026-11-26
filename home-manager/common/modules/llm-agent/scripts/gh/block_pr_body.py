#!/usr/bin/env python3
# Block PR creation and body edits that bypass pr-body.sh; reads the command from AGENT_RAW_COMMAND.

import json
import os
import re
import shlex
import subprocess
import sys
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path

import tree_sitter_bash
from graphql import GraphQLError, parse
from graphql.language import (
    FieldNode,
    ObjectValueNode,
    OperationDefinitionNode,
    OperationType,
    VariableNode,
)
from tree_sitter import Language, Node, Parser

WRAPPER = Path.home() / ".claude/scripts/gh/pr-body.sh"
CREATE_USAGE = f"{WRAPPER} --title <title> --body-file <path> [gh pr create の引数]"
EDIT_USAGE = f"{WRAPPER} --edit --body-file <path> [gh pr edit の引数]"

PULLS = re.compile(r"repos/[^/]+/[^/]+/pulls")
PULL = re.compile(r"repos/[^/]+/[^/]+/pulls/\d+")
ISSUE = re.compile(r"repos/(?P<owner>[^/]+)/(?P<repo>[^/]+)/issues/(?P<number>\d+)")
ASSIGNMENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*=")

WRAPPER_COMMANDS = {"command", "exec", "nohup", "nice", "env", "time", "rtk", "proxy"}
EXPANSIONS = {
    "simple_expansion",
    "expansion",
    "command_substitution",
    "process_substitution",
    "arithmetic_expansion",
    "ansi_c_string",
}
PR_EDIT_VALUE_OPTIONS = {"--body", "-b", "--body-file", "-F"}
API_VALUE_OPTIONS = {
    "-X",
    "--method",
    "-f",
    "--raw-field",
    "-F",
    "--field",
    "--input",
    "-H",
    "--header",
    "-q",
    "--jq",
    "-t",
    "--template",
    "--hostname",
    "-p",
    "--preview",
    "--cache",
}

PARSER = Parser(Language(tree_sitter_bash.language()))


class BlockedError(Exception):
    pass


def deny(command: str, usage: str) -> BlockedError:
    return BlockedError(
        f"Blocked: `{command}` は直接実行できない。\n"
        "PR bodyは、やったことを3行以内で書く。"
        "理由、見出し、動作確認、変更ファイルの列挙は書かない。\n"
        "bodyを一時ファイルに書いてから次を実行する。\n"
        f"  {usage}"
    )


def undecidable(command: str, reason: str) -> BlockedError:
    return BlockedError(
        f"Blocked: `{command}` がPRを作るか、PRのbodyを書き換えるかを判定できない。\n"
        f"理由: {reason}\n"
        "PRの作成とbodyの書き換えは、bodyを一時ファイルに書いてから次で行う。\n"
        f"  {CREATE_USAGE}\n"
        f"  {EDIT_USAGE}"
    )


@dataclass(frozen=True)
class Word:
    text: str
    static: bool


@dataclass(frozen=True)
class Command:
    words: list[Word]
    stdin: str | None


class Unknown:
    pass


UNKNOWN = Unknown()


def descendants(node: Node) -> Iterator[Node]:
    yield node
    for child in node.children:
        yield from descendants(child)


def to_word(node: Node) -> Word:
    source = (node.text or b"").decode()
    static = not any(n.type in EXPANSIONS for n in descendants(node))
    try:
        tokens = shlex.split(source)
    except ValueError:
        return Word(source, static=False)
    if len(tokens) == 1:
        return Word(tokens[0], static)
    return Word(source, static=False)


def heredoc_text(redirect: Node) -> str:
    body = next((c for c in redirect.children if c.type == "heredoc_body"), None)
    text = (body.text or b"").decode() if body else ""
    if any(c.type == "<<-" for c in redirect.children):
        return "\n".join(line.lstrip("\t") for line in text.split("\n"))
    return text


def read_file(path: str) -> str | None:
    file = Path(path)
    return file.read_text(encoding="utf-8") if file.is_file() else None


def is_stdin_redirect(redirect: Node) -> bool:
    if redirect.type == "file_redirect":
        return any(c.type == "<" for c in redirect.children)
    return redirect.type in {"heredoc_redirect", "herestring_redirect"}


def redirected_stdin(redirect: Node) -> str | None:
    if redirect.type == "heredoc_redirect":
        return heredoc_text(redirect)
    word = to_word(redirect.named_children[-1])
    if not word.static:
        return None
    if redirect.type == "herestring_redirect":
        return word.text + "\n"
    return read_file(word.text)


def to_command(node: Node) -> Command:
    redirects = node.children_by_field_name("redirect")
    if node.parent and node.parent.type == "redirected_statement":
        redirects += node.parent.children_by_field_name("redirect")
    name = node.child_by_field_name("name")
    arguments = node.children_by_field_name("argument")
    words = [to_word(n) for n in ([name] if name else []) + arguments]
    stdin_redirects = [r for r in redirects if is_stdin_redirect(r)]
    stdin = redirected_stdin(stdin_redirects[-1]) if stdin_redirects else None
    return Command(words, stdin)


def unwrap(words: list[Word]) -> list[Word]:
    while words and (
        words[0].text in WRAPPER_COMMANDS
        or words[0].text.startswith("-")
        or ASSIGNMENT.match(words[0].text)
    ):
        words = words[1:]
    return words


def gh_commands(script: str) -> Iterator[Command]:
    tree = PARSER.parse(script.encode())
    if tree.root_node.has_error:
        raise undecidable("gh", "コマンドを構文解析できない")
    for node in descendants(tree.root_node):
        if node.type != "command":
            continue
        command = to_command(node)
        words = unwrap(command.words)
        if words and words[0].text == "gh":
            yield Command(words[1:], command.stdin)


def options(args: list[Word], value_options: set[str]) -> Iterator[tuple[str | None, Word]]:
    rest = iter(args)
    for arg in rest:
        text = arg.text
        if not text.startswith("-") or text == "-":
            yield None, arg
        elif text.startswith("--") and "=" in text:
            name, _, value = text.partition("=")
            yield name, Word(value, arg.static)
        elif text in value_options:
            yield text, next(rest, Word("", static=True))
        elif text[:2] in value_options:
            yield text[:2], Word(text[2:], arg.static)
        else:
            yield text, arg


@dataclass(frozen=True)
class Field:
    key: str
    value: Word
    typed: bool


@dataclass
class ApiCall:
    endpoint: Word | None = None
    method: str | None = None
    input: Word | None = None
    fields: tuple[Field, ...] = ()


def parse_api(args: list[Word]) -> ApiCall:
    call = ApiCall()
    for name, value in options(args, API_VALUE_OPTIONS):
        match name:
            case None if call.endpoint is None:
                call.endpoint = value
            case "-X" | "--method":
                call.method = value.text.upper()
            case "--input":
                call.input = value
            case "-f" | "--raw-field" | "-F" | "--field":
                key, sep, text = value.text.partition("=")
                if sep:
                    typed = name in {"-F", "--field"}
                    call.fields += (Field(key, Word(text, value.static), typed),)
    if call.method is None:
        call.method = "POST" if call.fields or call.input else "GET"
    return call


def read_source(source: Word, stdin: str | None, label: str) -> str:
    content = None
    if source.static:
        content = stdin if source.text == "-" else read_file(source.text)
    if content is None:
        raise undecidable("gh api graphql", f"{label} の中身を読めない")
    return content


def field_value(field: Field, stdin: str | None) -> object:
    text = field.value.text
    if not field.value.static:
        return UNKNOWN
    if not field.typed:
        return text
    if text.startswith("@"):
        return read_source(Word(text[1:], static=True), stdin, f"{field.key}={text}")
    if text in {"true", "false", "null"}:
        return json.loads(text)
    if re.fullmatch(r"-?\d+", text):
        return int(text)
    return text


def put(node: object, path: list[str], value: object) -> object:
    if not path:
        return value
    head, rest = path[0], path[1:]
    if head == "":
        items = node if isinstance(node, list) else []
        return [*items, put(None, rest, value)]
    mapping = node if isinstance(node, dict) else {}
    return {**mapping, head: put(mapping.get(head), rest, value)}


def graphql_request(call: ApiCall, stdin: str | None) -> tuple[object, dict[str, object]]:
    request: object = {}
    if call.input:
        try:
            request = json.loads(read_source(call.input, stdin, f"--input {call.input.text}"))
        except json.JSONDecodeError:
            raise undecidable("gh api graphql", "--input の中身がJSONでない") from None
    if not isinstance(request, dict):
        raise undecidable("gh api graphql", "--input の中身がJSONのオブジェクトでない")
    query = request.get("query")
    variables = request.get("variables")
    for field in call.fields:
        value = field_value(field, stdin)
        head = field.key.split("[", 1)[0]
        path = [head, *re.findall(r"\[([^\]]*)\]", field.key[len(head) :])]
        if path == ["query"]:
            query = value
        elif path != ["operationName"]:
            variables = put(variables, path, value)
    return query, variables if isinstance(variables, dict) else {}


def updates_body(mutation: FieldNode, variables: dict[str, object]) -> bool:
    argument = next((a for a in mutation.arguments if a.name.value == "input"), None)
    if argument is None:
        return False
    value = argument.value
    if isinstance(value, ObjectValueNode):
        return any(f.name.value == "body" for f in value.fields)
    if isinstance(value, VariableNode):
        resolved = variables.get(value.name.value)
        if isinstance(resolved, dict):
            return "body" in resolved
        raise undecidable(
            "gh api graphql",
            f"updatePullRequestのinputに渡す変数 ${value.name.value} の中身が、"
            "コマンドから読み取れない",
        )
    raise undecidable("gh api graphql", "updatePullRequestのinputを解析できない")


def check_graphql(call: ApiCall, stdin: str | None) -> None:
    query, variables = graphql_request(call, stdin)
    if query is UNKNOWN:
        raise undecidable("gh api graphql", "queryの中身がコマンドから読み取れない")
    if not isinstance(query, str):
        return
    try:
        document = parse(query)
    except GraphQLError:
        raise undecidable("gh api graphql", "GraphQLのqueryを解析できない") from None
    for definition in document.definitions:
        if not (
            isinstance(definition, OperationDefinitionNode)
            and definition.operation == OperationType.MUTATION
        ):
            continue
        for selection in definition.selection_set.selections:
            if not isinstance(selection, FieldNode):
                raise undecidable("gh api graphql", "mutationのfragmentは解析しない")
            if selection.name.value == "createPullRequest":
                raise deny("gh api graphql createPullRequest", CREATE_USAGE)
            if selection.name.value == "updatePullRequest" and updates_body(selection, variables):
                raise deny("gh api graphql updatePullRequest", EDIT_USAGE)


def gh_output(*args: str) -> str:
    return subprocess.run(["gh", *args], capture_output=True, text=True, check=True).stdout.strip()


def ask_issue_is_pr(owner: str, repo: str, number: str) -> str:
    if "{owner}" in (owner, repo) or "{repo}" in (owner, repo):
        nwo = gh_output("repo", "view", "--json", "nameWithOwner", "--jq", ".nameWithOwner")
        current_owner, current_repo = nwo.split("/", 1)
        owner = current_owner if owner == "{owner}" else owner
        repo = current_repo if repo == "{repo}" else repo
    return gh_output(
        "api", f"repos/{owner}/{repo}/issues/{number}", "--jq", ".pull_request != null"
    )


def check_rest(call: ApiCall) -> None:
    if call.endpoint is None or not (call.input or any(f.key == "body" for f in call.fields)):
        return
    path = call.endpoint.text.lstrip("/").split("?", 1)[0]
    if call.method == "POST" and PULLS.fullmatch(path):
        raise deny("gh api POST /repos/<owner>/<repo>/pulls", CREATE_USAGE)
    if call.method == "PATCH" and PULL.fullmatch(path):
        raise deny("gh api PATCH /repos/<owner>/<repo>/pulls/<number>", EDIT_USAGE)
    issue = ISSUE.fullmatch(path)
    if call.method not in {"POST", "PATCH"} or issue is None:
        return
    number = issue["number"]
    command = f"gh api {call.method} /repos/<owner>/<repo>/issues/{number}"
    try:
        answer = ask_issue_is_pr(issue["owner"], issue["repo"], number)
    except OSError, ValueError, subprocess.CalledProcessError:
        raise undecidable(
            command, f"#{number} がPRかどうかをGitHubに問い合わせられなかった"
        ) from None
    if answer == "true":
        raise deny(command, f"{WRAPPER} --edit --body-file <path> {number}")
    if answer != "false":
        raise undecidable(
            command, f"#{number} がPRかどうかの問い合わせが想定しない結果を返した: {answer}"
        )


def check(command: Command) -> None:
    args = [word.text for word in command.words]
    match args:
        case ["pr", "create", *_]:
            raise deny("gh pr create", CREATE_USAGE)
        case ["pr", "edit", *_]:
            if any(
                name in PR_EDIT_VALUE_OPTIONS
                for name, _ in options(command.words[2:], PR_EDIT_VALUE_OPTIONS)
            ):
                raise deny("gh pr edit --body", EDIT_USAGE)
        case ["api", *_]:
            call = parse_api(command.words[1:])
            if call.endpoint and call.endpoint.text == "graphql":
                check_graphql(call, command.stdin)
            else:
                check_rest(call)


def main() -> None:
    script = os.environ.get("AGENT_RAW_COMMAND", "")
    try:
        if not script:
            raise undecidable("gh", "hookに元のコマンドが渡っていない")
        for command in gh_commands(script):
            check(command)
    except BlockedError as blocked:
        print(blocked, file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
