# Routes `agent` calls to whichever agent CLI spawned the caller (CLAUDECODE marks Claude Code, CHISEL_SESSION_DB marks Devin, CLAUDECODE wins when nested).
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
    local ret=$?
    # `devin -p` has no flag to skip session recording, so mark the sessions hidden afterwards to keep them out of `devin -r`.
    if ((${args[(Ie)-p]} || ${args[(Ie)--print]})); then
        (
            # Interactive user messages carry chisel/client-message-id but print and summarizer sessions never do, and the summarizer spawned later is itself a print session that sweeps itself on exit.
            nix run nixpkgs#sqlite -- "$CHISEL_SESSION_DB" "
                UPDATE sessions SET hidden = 1 WHERE hidden = 0
                  AND EXISTS (SELECT 1 FROM message_nodes m WHERE m.session_id = sessions.id
                    AND json_extract(m.chat_message, '$.role') = 'user')
                  AND NOT EXISTS (SELECT 1 FROM message_nodes m WHERE m.session_id = sessions.id
                    AND json_extract(m.chat_message, '$.metadata.extensions.\"chisel/client-message-id\"') IS NOT NULL)
            " >/dev/null 2>&1
        ) &!
    fi
    return $ret
}
