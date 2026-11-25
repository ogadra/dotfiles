#!/usr/bin/env bash
# Block PR creation and body edits that bypass the pr-body wrapper, which caps the body at three lines and runs readable-writing; input is one gh command per stdin line.
set -u

# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"

WRAPPER="$HOME/.claude/scripts/gh/pr-body.sh"
PULLS_RE="(^|[[:space:]\"'])/?repos/[^/[:space:]]+/[^/[:space:]]+/pulls([?\"'[:space:]]|$)"
PULL_RE="(^|[[:space:]\"'])/?repos/[^/[:space:]]+/[^/[:space:]]+/pulls/[0-9]+([?\"'[:space:]]|$)"
ISSUE_RE="(^|[[:space:]\"'])/?repos/([^/[:space:]\"']+)/([^/[:space:]\"']+)/issues/([0-9]+)([?\"'[:space:]]|$)"
US=$'\x1f'

deny() {
  cat >&2 <<EOF
Blocked: \`$1\` は直接実行できない。
PR bodyは、やったことを3行以内で書く。理由、見出し、動作確認、変更ファイルの列挙は書かない。
bodyを一時ファイルに書いてから次を実行する。
  $2
EOF
  exit 2
}

deny_unknown() {
  cat >&2 <<EOF
Blocked: \`$1\` がPRを作るか、PRのbodyを書き換えるかを判定できない。
理由: $2
PRの作成とbodyの書き換えは、bodyを一時ファイルに書いてから次で行う。
  $WRAPPER --title <title> --body-file <path> [gh pr create の引数]
  $WRAPPER --edit --body-file <path> [gh pr edit の引数]
EOF
  exit 2
}

has_body_flag() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --body|--body=*|-b|--body-file|--body-file=*|-F) return 0 ;;
    esac
  done
  return 1
}

has_api_body() {
  local arg
  while [ $# -gt 0 ]; do
    case "$1" in
      -f|-F|--field|--raw-field)
        arg=$(printf '%s' "${2:-}" | tr -d "\"'")
        case "$arg" in body=*) return 0 ;; esac
        shift
        ;;
      -f*|-F*|--field=*|--raw-field=*)
        arg=$(printf '%s' "${1#--*=}" | tr -d "\"'")
        arg=${arg#-[fF]}
        case "$arg" in body=*) return 0 ;; esac
        ;;
      --input|--input=*) return 0 ;;
    esac
    shift
  done
  return 1
}

issue_is_pr() {
  local owner=$1 repo=$2 nwo
  if [ "$owner" = "{owner}" ] || [ "$repo" = "{repo}" ]; then
    nwo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null) || return 1
    [ "$owner" = "{owner}" ] && owner=${nwo%%/*}
    [ "$repo" = "{repo}" ] && repo=${nwo#*/}
  fi
  gh api "repos/$owner/$repo/issues/$3" --jq '.pull_request != null' 2>/dev/null
}

_end_word() {
  [ "$inw" -eq 1 ] || return 0
  case "$pending" in
    "") words="${words}${w}${US}"; nwords=$((nwords + 1)) ;;
    infile) in_kind="file"; in_text=$w ;;
    herestring) in_kind=text; in_text="$w"$'\n' ;;
    heredoc|heredoc-)
      HD_IDX+=("${#CMDS[@]}")
      HD_DELIM+=("$w")
      HD_STRIP+=("${pending#heredoc}")
      in_kind=heredoc
      ;;
  esac
  pending=""
  w=""
  inw=0
}

_end_cmd() {
  _end_word
  if [ "$nwords" -gt 0 ] || [ -n "$in_kind" ]; then
    CMDS+=("$words")
    CMD_IN_KIND+=("$in_kind")
    CMD_IN+=("$in_text")
  fi
  words=""
  nwords=0
  in_kind=""
  in_text=""
}

_drop_fd() {
  if [ "$inw" -eq 1 ] && [ -z "$pending" ] && [[ "$w" =~ ^[0-9]+$ ]]; then
    w=""
    inw=0
  fi
}

_read_heredocs() {
  local k line rest body t
  k=$hd_next
  while [ "$k" -lt "${#HD_IDX[@]}" ]; do
    body=""
    while [ "$i" -lt "$n" ]; do
      rest=${s:i}
      line=${rest%%$'\n'*}
      i=$((i + ${#line} + 1))
      t=$line
      [ -n "${HD_STRIP[k]}" ] && t=${t#"${t%%[!$'\t']*}"}
      [ "$t" = "${HD_DELIM[k]}" ] && break
      body+="$t"$'\n'
    done
    CMD_IN_KIND[HD_IDX[k]]=text
    CMD_IN[HD_IDX[k]]=$body
    k=$((k + 1))
  done
  hd_next=$k
}

parse_commands() {
  local LC_ALL=C
  local s=$1 n=${#1} i=0 c d e w="" inw=0 pending="" words="" nwords=0 in_kind="" in_text="" rest chunk depth hd_next=0
  CMDS=()
  CMD_IN_KIND=()
  CMD_IN=()
  HD_IDX=()
  HD_DELIM=()
  HD_STRIP=()
  while [ "$i" -lt "$n" ]; do
    c=${s:i:1}
    case "$c" in
      "'")
        rest=${s:i+1}
        chunk=${rest%%\'*}
        w+=$chunk
        inw=1
        i=$((i + 2 + ${#chunk}))
        ;;
      '"')
        inw=1
        i=$((i + 1))
        while [ "$i" -lt "$n" ]; do
          d=${s:i:1}
          [ "$d" = '"' ] && break
          if [ "$d" = "\\" ]; then
            e=${s:i+1:1}
            case "$e" in
              '$'|'`'|'"'|"\\") w+=$e ;;
              $'\n') ;;
              *) w+="\\$e" ;;
            esac
            i=$((i + 2))
            continue
          fi
          w+=$d
          i=$((i + 1))
        done
        i=$((i + 1))
        ;;
      "\\")
        e=${s:i+1:1}
        if [ "$e" != $'\n' ]; then
          w+=$e
          inw=1
        fi
        i=$((i + 2))
        ;;
      ' '|$'\t')
        _end_word
        i=$((i + 1))
        ;;
      $'\n')
        _end_cmd
        i=$((i + 1))
        _read_heredocs
        ;;
      ';'|'('|')')
        _end_cmd
        i=$((i + 1))
        ;;
      '&')
        if [ "${s:i+1:1}" = ">" ]; then
          _end_word
          pending=out
          i=$((i + 2))
          [ "${s:i:1}" = ">" ] && i=$((i + 1))
        else
          _end_cmd
          i=$((i + 1))
        fi
        ;;
      '|')
        if [ "${s:i+1:1}" = "|" ]; then
          _end_cmd
          i=$((i + 2))
        else
          _end_cmd
          in_kind=pipe
          i=$((i + 1))
          [ "${s:i:1}" = "&" ] && i=$((i + 1))
        fi
        ;;
      '>')
        _drop_fd
        _end_word
        pending=out
        i=$((i + 1))
        while [ "${s:i:1}" = ">" ] || [ "${s:i:1}" = "|" ] || [ "${s:i:1}" = "&" ]; do
          i=$((i + 1))
        done
        ;;
      '<')
        _drop_fd
        _end_word
        if [ "${s:i:3}" = "<<<" ]; then
          pending=herestring
          i=$((i + 3))
        elif [ "${s:i:2}" = "<<" ]; then
          i=$((i + 2))
          if [ "${s:i:1}" = "-" ]; then
            pending=heredoc-
            i=$((i + 1))
          else
            pending=heredoc
          fi
        else
          pending=infile
          i=$((i + 1))
          [ "${s:i:1}" = "&" ] && i=$((i + 1))
        fi
        ;;
      '#')
        if [ "$inw" -eq 0 ]; then
          rest=${s:i}
          chunk=${rest%%$'\n'*}
          i=$((i + ${#chunk}))
        else
          w+=$c
          i=$((i + 1))
        fi
        ;;
      '$')
        inw=1
        if [ "${s:i+1:1}" = "(" ]; then
          depth=0
          while [ "$i" -lt "$n" ]; do
            d=${s:i:1}
            w+=$d
            i=$((i + 1))
            [ "$d" = "(" ] && depth=$((depth + 1))
            if [ "$d" = ")" ]; then
              depth=$((depth - 1))
              [ "$depth" -eq 0 ] && break
            fi
          done
        else
          w+=$c
          i=$((i + 1))
        fi
        ;;
      '`')
        rest=${s:i+1}
        chunk=${rest%%\`*}
        w+="\`$chunk\`"
        inw=1
        i=$((i + 2 + ${#chunk}))
        ;;
      *)
        w+=$c
        inw=1
        i=$((i + 1))
        ;;
    esac
  done
  _end_cmd
}

read_source() {
  case "$2" in
    -)
      case "${CMD_IN_KIND[$1]}" in
        text) printf '%s' "${CMD_IN[$1]}" ;;
        file) [ -f "${CMD_IN[$1]}" ] && cat -- "${CMD_IN[$1]}" ;;
        *) return 1 ;;
      esac
      ;;
    *) [ -f "$2" ] && cat -- "$2" ;;
  esac
}

read -r -d '' GRAPHQL_JQ <<'JQ'
def toks:
  [scan("\"\"\"(?:\\\\\"\"\"|[^\"]|\"(?!\"\"))*\"\"\"|\"(?:\\\\.|[^\"\\\\\\n])*\"|#[^\\n]*|\\.\\.\\.|[A-Za-z_][A-Za-z0-9_]*|-?[0-9][0-9.eE+-]*|[$!=@:{}()\\[\\]|&]")]
  | map(select(startswith("#") | not));
def group_end($t; $i):
  {j: $i, d: 0}
  | until(.j >= ($t | length) or (.d == 0 and .j > $i);
      $t[.j] as $x
      | .d += (if ($x == "{" or $x == "(" or $x == "[") then 1 elif ($x == "}" or $x == ")" or $x == "]") then -1 else 0 end)
      | .j += 1)
  | .j;
def value_end($t; $i): if $t[$i] == "$" then $i + 2 else group_end($t; $i) end;
def directives_end($t; $i):
  $i | until($t[.] != "@"; (. + 2) as $k | if $t[$k] == "(" then group_end($t; $k) else $k end);
def entries($t; $i; $close):
  {j: ($i + 1), out: []}
  | until(.j >= ($t | length) or $t[.j] == $close;
      .j as $j
      | if $t[$j + 1] == ":" then .out += [{key: $t[$j], v: ($j + 2)}] | .j = value_end($t; $j + 2)
        else .j = $j + 1 end)
  | .out;
def selections($t; $s):
  {j: ($s + 1), out: []}
  | until(.j >= ($t | length) or $t[.j] == "}";
      .j as $j
      | if $t[$j] == "..." then
          .out += [{spread: true}]
          | .j = ((if $t[$j + 1] == "on" then $j + 3 elif ($t[$j + 1] == "{" or $t[$j + 1] == "@") then $j + 1 else $j + 2 end)
              | directives_end($t; .) | if $t[.] == "{" then group_end($t; .) else . end)
        else
          (if $t[$j + 1] == ":" then {name: $t[$j + 2], k: ($j + 3)} else {name: $t[$j], k: ($j + 1)} end) as $f
          | .out += [{name: $f.name, args: (if $t[$f.k] == "(" then $f.k else null end)}]
          | .j = ($f.k | if $t[.] == "(" then group_end($t; .) else . end
              | directives_end($t; .) | if $t[.] == "{" then group_end($t; .) else . end)
        end)
  | .out;
def operations($t):
  {j: 0, out: []}
  | until(.j >= ($t | length);
      .j as $j | $t[$j] as $x
      | if ($x == "query" or $x == "mutation" or $x == "subscription") then
          ($j + 1 | if ($t[.] != "(" and $t[.] != "{" and $t[.] != "@") then . + 1 else . end
            | if $t[.] == "(" then group_end($t; .) else . end
            | directives_end($t; .)) as $s
          | if $t[$s] == "{" then .out += [{type: $x, set: $s}] | .j = group_end($t; $s)
            else .out += [{type: "error"}] | .j = ($t | length) end
        elif $x == "{" then .out += [{type: "query", set: $j}] | .j = group_end($t; $j)
        elif $x == "fragment" then
          ($j + 4 | directives_end($t; .)) as $s
          | if $t[$s] == "{" then .out += [{type: "fragment", set: $s}] | .j = group_end($t; $s)
            else .out += [{type: "error"}] | .j = ($t | length) end
        else .out += [{type: "error"}] | .j = ($t | length) end)
  | .out;
def update_body($t; $vars):
  if .args == null then "ok"
  else
    ([entries($t; .args; ")")[] | select(.key == "input")] | first) as $in
    | if $in == null then "ok"
      elif $t[$in.v] == "{" then (if any(entries($t; $in.v; "}")[]; .key == "body") then "body" else "ok" end)
      elif $t[$in.v] == "$" then
        $vars[$t[$in.v + 1]] as $val
        | if ($val | type) == "object" then (if $val | has("body") then "body" else "ok" end)
          else "unknown:updatePullRequestのinputに渡す変数 $\($t[$in.v + 1]) の中身が、コマンドから読み取れない" end
      else "unknown:updatePullRequestのinputを解析できない" end
  end;
def decide($t; $vars):
  operations($t) as $ops
  | if any($ops[]; .type == "error") then "unknown:GraphQLのqueryを解析できない"
    else
      [$ops[] | select(.type == "mutation") | selections($t; .set)[]] as $sel
      | if any($sel[]; .spread == true) then "unknown:mutationのfragmentは解析しない"
        elif any($sel[]; .name == "createPullRequest") then "create"
        else
          [$sel[] | select(.name == "updatePullRequest") | update_body($t; $vars)] as $u
          | if any($u[]; . == "body") then "body"
            else (first($u[] | select(startswith("unknown:"))) // "ok") end
        end
    end;
def typed:
  if .kind == "raw" then .v
  elif (.v == "true" or .v == "false" or .v == "null") then (.v | fromjson)
  elif (.v | test("^-?[0-9]+$")) then (.v | tonumber)
  else .v end;
def put($path; $v):
  if ($path | length) == 0 then $v
  elif $path[0] == "" then (. // []) + [null | put($path[1:]; $v)]
  else (. // {}) | .[$path[0]] |= put($path[1:]; $v) end;
try (
  $ARGS.positional as $p
  | [range(0; $p | length; 3) as $i | {k: $p[$i], kind: $p[$i + 1], v: $p[$i + 2]}] as $fields
  | (if $input == "" then {} else ($input | try fromjson catch error("--input の中身がJSONでない")) end) as $req
  | (if ($req | type) == "object" then $req else error("--input の中身がJSONのオブジェクトでない") end)
  | (if (.variables | type) == "object" then .variables else {} end) as $vars0
  | reduce $fields[] as $f ({query: .query, variables: $vars0};
      ($f.k | capture("^(?<h>[^\\[]*)(?<r>.*)$")) as $c
      | ([$c.h] + [$c.r | scan("\\[([^\\]]*)\\]") | .[0]]) as $path
      | if ($path == ["query"] or $path == ["operationName"]) then .[$path[0]] = ($f | typed)
        else .variables |= put($path; $f | typed) end)
  | if (.query | type) != "string" then "ok" else decide(.query | toks; .variables) end
) catch "unknown:\(.)"
JQ

check_graphql_command() {
  local k=$1 a endpoint="" input_src="" have_input=0 input_json="" spec key val kind content result idx
  local field_kinds=() field_specs=() jq_args=()
  shift
  while [ $# -gt 0 ]; do
    a=$1
    case "$a" in
      -f|--raw-field) field_kinds+=(raw); field_specs+=("${2-}"); shift ;;
      -F|--field) field_kinds+=(typed); field_specs+=("${2-}"); shift ;;
      --raw-field=*) field_kinds+=(raw); field_specs+=("${a#*=}") ;;
      --field=*) field_kinds+=(typed); field_specs+=("${a#*=}") ;;
      -f?*) field_kinds+=(raw); field_specs+=("${a#-f}") ;;
      -F?*) field_kinds+=(typed); field_specs+=("${a#-F}") ;;
      --input) input_src=${2-}; have_input=1; shift ;;
      --input=*) input_src=${a#*=}; have_input=1 ;;
      -X|--method|-H|--header|-q|--jq|-t|--template|--hostname|-p|--preview|--cache) shift ;;
      -*) ;;
      *) [ -n "$endpoint" ] || endpoint=$a ;;
    esac
    shift
  done
  [ "$endpoint" = graphql ] || return 0

  if [ "$have_input" -eq 1 ]; then
    input_json=$(read_source "$k" "$input_src") || deny_unknown 'gh api graphql' "--input $input_src の中身を読めない"
  fi
  idx=0
  while [ "$idx" -lt "${#field_specs[@]}" ]; do
    spec=${field_specs[idx]}
    kind=${field_kinds[idx]}
    idx=$((idx + 1))
    case "$spec" in *=*) ;; *) continue ;; esac
    key=${spec%%=*}
    val=${spec#*=}
    if [ "$kind" = typed ] && [ "${val#@}" != "$val" ]; then
      content=$(read_source "$k" "${val#@}") || deny_unknown 'gh api graphql' "$key=$val の中身を読めない"
      val=$content
      kind=raw
    fi
    jq_args+=("$key" "$kind" "$val")
  done

  result=$(jq -rn --arg input "$input_json" "$GRAPHQL_JQ" --args ${jq_args[@]+"${jq_args[@]}"}) \
    || deny_unknown 'gh api graphql' 'GraphQLの判定が失敗した'
  case "$result" in
    ok) ;;
    create) deny 'gh api graphql createPullRequest' "$WRAPPER --title <title> --body-file <path> [gh pr create の引数]" ;;
    body) deny 'gh api graphql updatePullRequest' "$WRAPPER --edit --body-file <path> [gh pr edit の引数]" ;;
    unknown:*) deny_unknown 'gh api graphql' "${result#unknown:}" ;;
    *) deny_unknown 'gh api graphql' "GraphQLの判定が想定しない結果を返した: $result" ;;
  esac
}

check_graphql() {
  local k rest words
  [ -n "$RAW_COMMAND" ] || deny_unknown 'gh api' 'hookに元のコマンドが渡っていない'
  parse_commands "$RAW_COMMAND"
  k=0
  while [ "$k" -lt "${#CMDS[@]}" ]; do
    words=()
    rest=${CMDS[k]}
    while [ -n "$rest" ]; do
      words+=("${rest%%"$US"*}")
      rest=${rest#*"$US"}
    done
    while [ "${#words[@]}" -gt 0 ]; do
      case "${words[0]}" in
        command|exec|nohup|nice|env|time|if|then|else|elif|do|while|until|'!'|'{'|rtk|proxy|-*) ;;
        *) [[ "${words[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || break ;;
      esac
      words=("${words[@]:1}")
    done
    if [ "${#words[@]}" -ge 2 ] && [ "${words[0]}" = gh ] && [ "${words[1]}" = api ]; then
      check_graphql_command "$k" "${words[@]:2}"
    fi
    k=$((k + 1))
  done
}

API=0
while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "gh pr create"|"gh pr create "*)
      deny 'gh pr create' "$WRAPPER --title <title> --body-file <path> [gh pr create の引数]"
      ;;
    "gh pr edit "*)
      # shellcheck disable=SC2086
      set -- $SEG
      if has_body_flag "$@"; then
        deny 'gh pr edit --body' "$WRAPPER --edit --body-file <path> [gh pr edit の引数]"
      fi
      ;;
    "gh api "*)
      API=1
      # shellcheck disable=SC2086
      set -- $SEG
      has_api_body "$@" || continue
      METHOD=$(rest_method "$SEG")
      if [ "$METHOD" = "POST" ] && printf '%s\n' "$SEG" | grep -Eq "$PULLS_RE"; then
        deny 'gh api POST /repos/<owner>/<repo>/pulls' "$WRAPPER --title <title> --body-file <path> [gh pr create の引数]"
      fi
      if [ "$METHOD" = "PATCH" ] && printf '%s\n' "$SEG" | grep -Eq "$PULL_RE"; then
        deny 'gh api PATCH /repos/<owner>/<repo>/pulls/<number>' "$WRAPPER --edit --body-file <path> [gh pr edit の引数]"
      fi
      if { [ "$METHOD" = "POST" ] || [ "$METHOD" = "PATCH" ]; } && [[ "$SEG" =~ $ISSUE_RE ]]; then
        NUMBER=${BASH_REMATCH[4]}
        IS_PR=$(issue_is_pr "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "$NUMBER") \
          || deny_unknown "gh api $METHOD /repos/<owner>/<repo>/issues/$NUMBER" "#$NUMBER がPRかどうかをGitHubに問い合わせられなかった"
        case "$IS_PR" in
          true) deny "gh api $METHOD /repos/<owner>/<repo>/issues/$NUMBER" "$WRAPPER --edit --body-file <path> $NUMBER" ;;
          false) ;;
          *) deny_unknown "gh api $METHOD /repos/<owner>/<repo>/issues/$NUMBER" "#$NUMBER がPRかどうかの問い合わせが想定しない結果を返した: $IS_PR" ;;
        esac
      fi
      ;;
  esac
done

[ "$API" -eq 0 ] || check_graphql
exit 0
