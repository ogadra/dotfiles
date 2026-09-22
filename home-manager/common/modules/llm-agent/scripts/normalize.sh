#!/usr/bin/env bash
# Read a shell command on stdin and print one normalized simple command per line for the guard scripts.
set -u

CMD=$(cat)

# A trailing backslash continues the command, so join it before splitting or the tail of the command escapes every guard
CMD="${CMD//\\$'\n'/ }"

# Reduce a git invocation to "git <subcommand> ..." so guards can match the subcommand without knowing the global options
strip_git_globals() {
  # shellcheck disable=SC2086
  set -- $1
  shift # drop "git"
  while [ $# -gt 0 ]; do
    case "$1" in
      # Global options that take their value as the next word
      -C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--config-env|--attr-source)
        shift 2 || break
        ;;
      -*)
        shift
        ;;
      *)
        break
        ;;
    esac
  done
  if [ $# -eq 0 ]; then
    printf 'git\n'
  else
    printf 'git %s\n' "$*"
  fi
}

while IFS= read -r SEG; do
  # Collapse runs of whitespace so patterns can assume single spaces between words
  SEG=$(printf '%s' "$SEG" | tr -s '[:space:]' ' ')
  SEG="${SEG#"${SEG%%[![:space:]]*}"}"
  SEG="${SEG%"${SEG##*[![:space:]]}"}"

  # Five rounds cover realistic stacking such as "( VAR=1 env git ..."
  for _ in 1 2 3 4 5; do
    if [[ "$SEG" =~ ^(\$\(|\(|\{|!|\`)[[:space:]]*(.*)$ ]]; then
      SEG="${BASH_REMATCH[2]}"
    elif [[ "$SEG" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; then
      SEG="${BASH_REMATCH[1]}"
    # sudo and xargs stay out of this list so pre-bash.sh can still deny them by name
    elif [[ "$SEG" =~ ^(command|exec|nohup|nice|env|time)[[:space:]]+(.*)$ ]]; then
      SEG="${BASH_REMATCH[2]}"
    elif [[ "$SEG" =~ ^\\(.*)$ ]]; then
      SEG="${BASH_REMATCH[1]}"
    else
      break
    fi
  done

  [ -n "$SEG" ] || continue
  case "$SEG" in
    "git"|"git "*) strip_git_globals "$SEG" ;;
    *) printf '%s\n' "$SEG" ;;
  esac
done < <(printf '%s\n' "$CMD" | tr ';&|' '\n')
