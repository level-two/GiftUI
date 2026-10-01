#!/usr/bin/env python3
"""Compare identical analyzer text pixels in native Pi/nRF captures."""

import argparse
from pathlib import Path


def region(data, width, x, y, w, h):
    return b"".join(data[2 * ((y + row) * width + x):
                         2 * ((y + row) * width + x + w)] for row in range(h))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pi", type=Path, required=True)
    parser.add_argument("--nrf", type=Path, required=True)
    args = parser.parse_args()
    states = ("idle", "running-four-traces", "stopped", "cleared",
              "window-one-second", "window-five-seconds", "window-two-seconds",
              "diagnostic")
    # Header/status and controls are centered; labels flank each plot.
    regions = (("title and subtitle", 12, 52, 4, 216, 42),
               ("status", 12, 52, 50, 216, 20),
               ("channel labels", 4, 4, 94, 36, 80),
               ("state labels", 194, 274, 94, 42, 80),
               ("controls", 60, 100, 180, 120, 40))
    for state in states:
        pi = (args.pi / f"pi-{state}.rgb565").read_bytes()
        nrf = (args.nrf / f"nrf-{state}.rgb565").read_bytes()
        assert len(pi) == 240 * 240 * 2 and len(nrf) == 320 * 240 * 2
        for name, px, nx, y, w, h in regions:
            # Fault injection enters different acquisition states on these hosts.
            if state == "diagnostic" and name in ("status", "state labels", "controls"):
                continue
            assert region(pi, 240, px, y, w, h) == region(nrf, 320, nx, y, w, h), \
                f"{state}: {name} text differs"
    print(f"PASS: identical Pi/nRF text pixels across {len(states)} states (diagnostic: title/subtitle and channel labels)")


if __name__ == "__main__":
    main()
