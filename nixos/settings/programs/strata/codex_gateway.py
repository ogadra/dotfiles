"""List Strata among codex's OpenAI models, and send the strata model's requests to Strata."""

import base64
import copy
import json
import logging
import os
import uuid

from aiohttp import ClientConnectorError, ClientSession, ClientTimeout, web

LISTEN_PORT = int(os.environ["GATEWAY_PORT"])
STRATA_URL = os.environ["STRATA_URL"]
STRATA_MODEL = os.environ["STRATA_MODEL"]
STRATA_CONTEXT_TOKENS = int(os.environ["STRATA_CONTEXT_TOKENS"])

# codex keeps its ChatGPT routes only while the base URL ends with this
PREFIX = "/backend-api/codex"
CHATGPT_URL = "https://chatgpt.com/backend-api/codex"
API_URL = "https://api.openai.com/v1"

# Item types Strata answered 200 to; it rejects every other type with a 400
STRATA_ITEM_TYPES = {
    "message",
    "reasoning",
    "function_call",
    "function_call_output",
    "custom_tool_call",
    "custom_tool_call_output",
}
# Marks a compaction item this gateway wrote, so its summary can be read back
SUMMARY_MARKER = "strata-summary:"
SUMMARY_PREFIX = "Summary of the earlier conversation, written when the context was compacted:\n\n"
SUMMARY_PROMPT = (
    "Your context is about to be compacted. "
    "Write a handoff summary for yourself to continue the task: "
    "the user's goals and constraints, decisions made, files and commands involved, what is done, "
    "and the exact next steps. Reply with the summary only."
)

HOP_BY_HOP = {
    "connection",
    "content-length",
    "host",
    "keep-alive",
    "proxy-connection",
    "te",
    "trailer",
    "transfer-encoding",
    "upgrade",
}

# No total limit: answers stream for minutes, and Strata may first load the model
TIMEOUT = ClientTimeout(total=None, sock_connect=10, sock_read=900)


def strata_entry(models):
    """Clone an OpenAI catalog entry, so the strata entry keeps fields this codex requires."""
    template = next((m for m in models if m.get("slug") == "gpt-5.5"), models[-1])
    entry = copy.deepcopy(template)
    entry.update(
        {
            "slug": STRATA_MODEL,
            "display_name": "Strata (local)",
            "description": "Qwen3.8-Flash-Next on this PC's Strata server.",
            "visibility": "list",
            # Lower sorts first; the local model goes below OpenAI's
            "priority": 1000,
            "upgrade": None,
            "availability_nux": None,
            # HTTP only: this gateway refuses WebSocket upgrades
            "prefer_websockets": False,
            "context_window": STRATA_CONTEXT_TOKENS,
            "max_context_window": STRATA_CONTEXT_TOKENS,
            # Tokens; about half the window, leaving room for codex's ~8.6K system prompt and tools
            "auto_compact_token_limit": STRATA_CONTEXT_TOKENS // 2,
            "default_reasoning_level": None,
            "supported_reasoning_levels": [],
            "supports_reasoning_effort_updates": False,
            "default_reasoning_summary": "auto",
            "support_verbosity": False,
            "default_verbosity": None,
            # Strata has no hosted tools, image detail or multi-agent support
            "web_search_tool_type": "text",
            "input_modalities": ["text"],
            "supports_image_detail_original": False,
            "tool_mode": None,
            "multi_agent_version": None,
            "multi_agent_reasoning_effort": None,
            "use_responses_lite": False,
            "include_skills_usage_instructions": False,
            "include_apps_usage_instructions": False,
            "include_plugin_usage_instructions": False,
            "comp_hash": None,
        }
    )
    return entry


def encode_summary(text):
    return SUMMARY_MARKER + base64.b64encode(text.encode()).decode()


def decode_summary(item):
    content = item.get("encrypted_content") or ""
    if not content.startswith(SUMMARY_MARKER):
        return None
    return base64.b64decode(content[len(SUMMARY_MARKER) :]).decode()


def summary_message(text):
    return {
        "type": "message",
        "role": "user",
        "content": [{"type": "input_text", "text": SUMMARY_PREFIX + text}],
    }


def for_strata(items):
    """Keep what Strata accepts, and turn this gateway's compaction items into their summary."""
    kept = []
    for item in items:
        kind = item.get("type")
        if kind == "compaction":
            text = decode_summary(item)
            # A compaction by OpenAI is encrypted, so its content is lost to Strata
            if text is not None:
                kept.append(summary_message(text))
        elif kind == "reasoning":
            # OpenAI's reasoning is encrypted and useless to Strata
            if not item.get("encrypted_content"):
                kept.append(item)
        elif kind in STRATA_ITEM_TYPES:
            kept.append(item)
    return kept


def for_openai(items):
    """Turn Strata's leftovers into what OpenAI accepts; returns None when nothing changes."""
    changed = False
    kept = []
    for item in items:
        kind = item.get("type")
        if kind == "compaction" and (text := decode_summary(item)) is not None:
            kept.append(summary_message(text))
            changed = True
        elif kind == "reasoning" and not item.get("encrypted_content"):
            # Strata's plain reasoning; OpenAI only takes back its own encrypted reasoning
            changed = True
        else:
            kept.append(item)
    return kept if changed else None


def upstream_headers(request):
    # aiohttp has already decoded codex's zstd body, so it goes upstream uncompressed
    return {
        k: v
        for k, v in request.headers.items()
        if k.lower() not in HOP_BY_HOP and k.lower() != "content-encoding"
    }


def upstream_base(request):
    # ChatGPT sign-in sends its account; an API key goes to the public API
    return CHATGPT_URL if "chatgpt-account-id" in request.headers else API_URL


async def relay(request, response):
    out = web.StreamResponse(
        status=response.status,
        headers={k: v for k, v in response.headers.items() if k.lower() not in HOP_BY_HOP},
    )
    await out.prepare(request)
    async for chunk in response.content.iter_any():
        await out.write(chunk)
    await out.write_eof()
    return out


def sse(event):
    return f"event: {event['type']}\ndata: {json.dumps(event)}\n\n".encode()


async def compact_on_strata(request, session, body, items):
    """Answer codex's remote compaction the way OpenAI does, with a summary Strata writes."""
    summary_request = {
        "model": STRATA_MODEL,
        "stream": False,
        "store": False,
        "input": [*for_strata(items), summary_message_request()],
        # The history refers to these tools; "none" stops the model calling them mid-summary
        "tool_choice": "none",
    }
    for key in ("instructions", "tools"):
        if key in body:
            summary_request[key] = body[key]
    async with session.post(f"{STRATA_URL}/responses", json=summary_request) as response:
        result = await response.json()
        if response.status != 200:
            return web.json_response(result, status=response.status)
    text = "".join(
        part.get("text", "")
        for item in result.get("output", [])
        if item.get("type") == "message"
        for part in item.get("content", [])
    )
    response_id = result.get("id") or f"resp_{uuid.uuid4().hex}"
    out = web.StreamResponse(headers={"Content-Type": "text/event-stream"})
    await out.prepare(request)
    await out.write(sse({"type": "response.created", "response": {"id": response_id}}))
    await out.write(
        sse(
            {
                "type": "response.output_item.done",
                "output_index": 0,
                "item": {"type": "compaction", "encrypted_content": encode_summary(text)},
            }
        )
    )
    await out.write(
        sse(
            {
                "type": "response.completed",
                "response": {"id": response_id, "usage": result.get("usage")},
            }
        )
    )
    await out.write_eof()
    return out


def summary_message_request():
    return {
        "type": "message",
        "role": "user",
        "content": [{"type": "input_text", "text": SUMMARY_PROMPT}],
    }


async def responses_to_strata(request, session, body):
    items = body.get("input", [])
    try:
        if items and items[-1].get("type") == "compaction_trigger":
            return await compact_on_strata(request, session, body, items[:-1])
        body["input"] = for_strata(items)
        async with session.post(f"{STRATA_URL}/responses", json=body) as response:
            return await relay(request, response)
    except ClientConnectorError:
        return web.json_response(
            {
                "error": {
                    "message": "Strata is not running; start it with strata-serve",
                    "type": "server_error",
                }
            },
            status=503,
        )


async def handle(request):
    if request.headers.get("Upgrade", "").lower() == "websocket":
        # 426 makes codex fall back to HTTP for the session, so every request can be read and routed
        return web.Response(status=426, text="WebSocket is not supported by this gateway")
    session = request.app["session"]
    path = request.match_info["path"]
    raw = await request.read()
    headers = upstream_headers(request)

    if path == "responses" and request.method == "POST":
        body = json.loads(raw)
        if body.get("model") == STRATA_MODEL:
            return await responses_to_strata(request, session, body)
        items = for_openai(body.get("input", []))
        if items is not None:
            body["input"] = items
            raw = json.dumps(body).encode()

    if path == "models":
        # The catalog is rewritten below, so ask for it uncompressed
        headers = {k: v for k, v in headers.items() if k.lower() != "accept-encoding"}

    url = f"{upstream_base(request)}/{path}"
    async with session.request(
        request.method, url, params=request.query, headers=headers, data=raw or None
    ) as response:
        if path == "models" and request.method == "GET" and response.status == 200:
            catalog = await response.json()
            models = catalog.get("models", [])
            if models and not any(m.get("slug") == STRATA_MODEL for m in models):
                models.append(strata_entry(models))
            # The body changed, so the upstream ETag no longer describes it
            return web.json_response(catalog)
        return await relay(request, response)


async def open_session(app):
    # auto_decompress off so encoded upstream bodies reach codex with their own Content-Encoding
    app["session"] = ClientSession(timeout=TIMEOUT, auto_decompress=False)
    yield
    await app["session"].close()


def main():
    logging.basicConfig(level=logging.INFO)
    app = web.Application(client_max_size=256 * 1024 * 1024)
    app.cleanup_ctx.append(open_session)
    app.router.add_route("*", PREFIX + "/{path:.*}", handle)
    web.run_app(app, host="127.0.0.1", port=LISTEN_PORT, access_log=None)


if __name__ == "__main__":
    main()
