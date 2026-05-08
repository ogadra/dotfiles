#!/usr/bin/env bash
# PreToolUse(Bash) hook: block `git push` to the remote's default branch.
set -u

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""')
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null

# Iterate each ;/&&/|| separated segment so chained pushes are also caught.
# Use process substitution so `exit 2` terminates the script, not just a pipeline subshell.
while IFS= read -r SEG; do
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  case "$SEG" in
    "git push"|"git push "*) ;;
    *) continue ;;
  esac

  # shellcheck disable=SC2086
  set -- $SEG
  shift # drop "git"
  shift # drop "push"
  REMOTE=""
  REFSPEC=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --repo|-o|--push-option|--receive-pack|--exec|--upload-pack)
        shift 2 || break
        continue
        ;;
      --repo=*|-o=*|--push-option=*|--receive-pack=*|--exec=*|--upload-pack=*)
        shift
        continue
        ;;
      -*)
        shift
        continue
        ;;
    esac
    if [ -z "$REMOTE" ]; then
      REMOTE="$1"
    elif [ -z "$REFSPEC" ]; then
      REFSPEC="$1"
    fi
    shift
  done

  # Extract the remote-side branch from the refspec (dst side of src:dst).
  # When refspec has no ':', src and dst are the same.
  REFSPEC="${REFSPEC#+}"
  case "$REFSPEC" in
    *:*) TARGET="${REFSPEC#*:}" ;;
    *)   TARGET="$REFSPEC"      ;;
  esac
  if [ -z "$TARGET" ]; then
    TARGET=$(git symbolic-ref --short HEAD 2>/dev/null) || continue
  fi

  [ -n "$REMOTE" ] || REMOTE="origin"
  DEFAULT=$(git symbolic-ref --short "refs/remotes/$REMOTE/HEAD" 2>/dev/null) || continue
  DEFAULT="${DEFAULT#"$REMOTE"/}"
  [ -n "$DEFAULT" ] || continue

  if [ "$TARGET" = "$DEFAULT" ]; then
    printf 'Blocked: pushing to default branch "%s" on "%s" is not allowed. Open a PR instead.\n' "$DEFAULT" "$REMOTE" >&2
    exit 2
  fi
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')
exit 0
