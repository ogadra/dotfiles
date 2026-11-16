"""Print key events from xremap's output device for the given number of seconds."""

import select
import struct
import sys
import time
from pathlib import Path

NAMES = {
    1: "ESC",
    14: "BACKSPACE",
    15: "TAB",
    16: "Q",
    17: "W",
    18: "E",
    19: "R",
    20: "T",
    21: "Y",
    22: "U",
    23: "I",
    24: "O",
    25: "P",
    26: "[",
    27: "]",
    28: "ENTER",
    29: "LEFTCTRL",
    30: "A",
    31: "S",
    32: "D",
    33: "F",
    34: "G",
    35: "H",
    36: "J",
    37: "K",
    38: "L",
    42: "LEFTSHIFT",
    44: "Z",
    45: "X",
    46: "C",
    47: "V",
    48: "B",
    49: "N",
    50: "M",
    54: "RIGHTSHIFT",
    56: "LEFTALT",
    57: "SPACE",
    58: "CAPSLOCK",
    97: "RIGHTCTRL",
    100: "RIGHTALT",
    125: "LEFTMETA",
    126: "RIGHTMETA",
}
STATES = {0: "up", 1: "down"}
# struct input_event on 64-bit Linux: timeval (two longs), type, code, value
EVENT = struct.Struct("llHHi")
EV_KEY = 1


def xremap_device() -> Path:
    """Find xremap's virtual device, since its event number changes on every restart."""
    name = None
    with Path("/proc/bus/input/devices").open() as devices:
        for line in devices:
            if line.startswith("N: Name="):
                name = line.split("=", 1)[1].strip().strip('"')
            elif line.startswith("H: Handlers=") and name == "xremap":
                event = next(h for h in line.split("=", 1)[1].split() if h.startswith("event"))
                return Path("/dev/input") / event
    raise SystemExit("xremap device not found; is xremap running?")


def main() -> None:
    seconds = float(sys.argv[1])
    end = time.time() + seconds
    with xremap_device().open("rb") as device:
        while time.time() < end:
            ready, _, _ = select.select([device], [], [], 0.5)
            if not ready:
                continue
            _, _, kind, code, value = EVENT.unpack(device.read(EVENT.size))
            # Value 2 is key repeat, which floods the log while a modifier is held
            if kind == EV_KEY and value in STATES:
                print(NAMES.get(code, code), STATES[value], flush=True)


if __name__ == "__main__":
    main()
