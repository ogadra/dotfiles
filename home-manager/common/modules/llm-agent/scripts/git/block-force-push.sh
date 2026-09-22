#!/usr/bin/env bash
set -u

deny() {
  printf 'Blocked: `git push %s` rewrites remote history. Pushed commits must not be amended or rebased.\n' "$1" >&2
  printf 'Find the pushed commit with `git reflog`, restore the branch with `git reset --hard <sha>`, then redo the change as a new commit.\n' >&2
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
  shift
  shift
  END_OF_OPTS=0
  while [ $# -gt 0 ]; do
    if [ "$END_OF_OPTS" -eq 0 ]; then
      case "$1" in
        --)
          END_OF_OPTS=1
          shift
          continue
          ;;
        --for*)
          deny "$1"
          ;;
        --repo|-o|--push-option|--receive-pack|--exec|--upload-pack)
          shift 2 || break
          continue
          ;;
        --*)
          shift
          continue
          ;;
        -*)
          case "$1" in
            *f*) deny "$1" ;;
          esac
          shift
          continue
          ;;
      esac
    fi
    case "$1" in
      +*) deny "$1" ;;
    esac
    shift
  done
done
exit 0
