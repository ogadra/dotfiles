#!/usr/bin/env bash
# Block `git push` that updates a default branch; input is one git command per stdin line.
set -u

deny() {
  printf 'Blocked: pushing to "%s" on "%s" is not allowed. Open a PR instead.\n' "$1" "$2" >&2
  exit 2
}

while IFS= read -r SEG; do
  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git push"|"git push "*) ;;
    *) continue ;;
  esac

  # shellcheck disable=SC2086
  set -- $SEG
  shift # drop "git"
  shift # drop "push"
  REMOTE=""
  REFSPECS=""
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
    else
      REFSPECS="$REFSPECS $1"
    fi
    shift
  done

  [ -n "$REMOTE" ] || REMOTE="origin"
  # main and master stay unconditional so a push that dodges remote-HEAD resolution, such as a URL remote, still hits the wall.
  DEFAULTS="main master $(git config --get init.defaultBranch 2>/dev/null)"
  REMOTE_HEAD=$(git symbolic-ref --quiet --short "refs/remotes/$REMOTE/HEAD" 2>/dev/null)
  DEFAULTS="$DEFAULTS ${REMOTE_HEAD#"$REMOTE"/}"

  REFSPECS="${REFSPECS# }"
  # An empty refspec means the current branch under push.default=nothing, so HEAD stands in for it.
  [ -n "$REFSPECS" ] || REFSPECS="HEAD"
  for R in $REFSPECS; do
    R="${R#+}"
    if [ "$R" = ":" ]; then
      for B in $(git for-each-ref --format='%(refname:short)' refs/heads); do
        for D in $DEFAULTS; do
          [ "$B" = "$D" ] && deny "$B" "$REMOTE"
        done
      done
      continue
    fi
    # The dst half of src:dst is the remote-side name; it equals src when there is no ':'.
    case "$R" in
      *:*) TARGET="${R#*:}" ;;
      *)   TARGET="$R"      ;;
    esac
    TARGET="${TARGET#refs/heads/}"
    # A bare or HEAD refspec means the current branch, so resolve it before comparing.
    if [ -z "$TARGET" ] || [ "$TARGET" = "HEAD" ]; then
      TARGET=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || continue
    fi
    for D in $DEFAULTS; do
      [ "$TARGET" = "$D" ] && deny "$TARGET" "$REMOTE"
    done
  done
done
exit 0
