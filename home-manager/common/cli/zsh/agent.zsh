# Routes `agent` calls to whichever agent CLI spawned the caller: Claude Code exports
# CLAUDECODE and Devin exports CHISEL_SESSION_DB to their tool environments, and
# CLAUDECODE wins because the innermost agent is the caller. Lives in .zshenv so
# `zsh -c 'agent ...'` callers such as review.sh can reach it from any shell.
agent() {
    if [[ -z $CHISEL_SESSION_DB || -n $CLAUDECODE ]]; then
        command claude "$@"
        return
    fi
    # `devin -p` has no --json-schema flag, so the schema is folded into the -p prompt
    local -a args
    local schema
    while (($#)); do
        case $1 in
            --json-schema)
                schema=$2
                shift
                (($#)) && shift
                ;;
            *)
                args+=("$1")
                shift
                ;;
        esac
    done
    if [[ -n $schema ]]; then
        local i
        for ((i = 1; i < $#args; i++)); do
            # The prompt is the first non-flag argument after -p/--print; without one the schema is dropped
            if [[ (${args[i]} == -p || ${args[i]} == --print) && ${args[i + 1]} != -* ]]; then
                args[i+1]+=$'\n\n'"Reply with only a JSON object conforming to this JSON Schema, without markdown fences:"$'\n'"$schema"
                break
            fi
        done
    fi
    command devin "${args[@]}"
}
