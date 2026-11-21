"""Unload Strata's model before ComfyUI runs a job, so both can stay up on one GPU."""

import logging
import urllib.error
import urllib.request

from server import PromptServer

# wait=1 lets an answer Strata is writing finish, for up to 300 s
STRATA_UNLOAD_URL = "http://127.0.0.1:8792/unload?wait=1"
# Seconds; a little above Strata's own 300 s wait
TIMEOUT_S = 310

NODE_CLASS_MAPPINGS = {}


def unload_strata(json_data):
    # Blocks ComfyUI's server on purpose: the job must not start before the VRAM is free
    request = urllib.request.Request(
        STRATA_UNLOAD_URL,
        data=b"{}",
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT_S) as response:
            logging.info("strata_gate: unload answered %s", response.status)
    except urllib.error.URLError as error:
        # strata-serve may not be running, and then there is nothing to unload
        logging.info("strata_gate: Strata did not answer: %s", error)
    return json_data


PromptServer.instance.add_on_prompt_handler(unload_strata)
