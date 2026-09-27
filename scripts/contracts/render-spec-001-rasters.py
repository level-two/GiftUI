#!/usr/bin/env python3
"""Render recorded RGB565 frames and compare them with reviewed references."""

import argparse
import hashlib
import pathlib
import struct
import sys
import zlib

EXTENTS = {"pi": (240, 240), "nrf": (480, 320)}
INVARIANT_RECTS = {
    "pi": ((4, 0, 160, 32), (75, 137, 165, 174)),
    "nrf": ((4, 0, 220, 32), (170, 170, 310, 220)),
}
STATES = (
    "idle",
    "running-four-traces",
    "stopped",
    "cleared",
    "window-one-second",
    "window-five-seconds",
    "window-two-seconds",
)


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(
        ">I", zlib.crc32(kind + data)
    )


def png(path, pixels, width, height):
    rows = bytearray()
    for y in range(height):
        rows.append(0)
        for x in range(width):
            offset = (y * width + x) * 2
            value = pixels[offset] << 8 | pixels[offset + 1]
            rows.extend(
                (
                    (value >> 11) * 255 // 31,
                    ((value >> 5) & 63) * 255 // 63,
                    (value & 31) * 255 // 31,
                )
            )
    path.write_bytes(
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
        + chunk(b"IEND", b"")
    )


def region_bytes(pixels, width, rect):
    left, top, right, bottom = rect
    return b"".join(
        pixels[(y * width + left) * 2 : (y * width + right) * 2]
        for y in range(top, bottom)
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--profile", choices=("pi", "nrf"), required=True)
    parser.add_argument("--captures", type=pathlib.Path, required=True)
    parser.add_argument("--images", type=pathlib.Path, required=True)
    parser.add_argument("--references", type=pathlib.Path)
    parser.add_argument("--include-diagnostic", action="store_true")
    args = parser.parse_args()
    args.images.mkdir(parents=True, exist_ok=True)
    failed = False
    invariant_baseline = None
    width, height = EXTENTS[args.profile]
    for state in STATES + (("diagnostic",) if args.include_diagnostic else ()):
        name = f"{args.profile}-{state}"
        path = args.captures / f"{name}.rgb565"
        data = path.read_bytes()
        if len(data) != width * height * 2:
            raise ValueError(f"{path}: expected {width * height * 2} bytes, got {len(data)}")
        invariant_regions = tuple(
            region_bytes(data, width, rect) for rect in INVARIANT_RECTS[args.profile]
        )
        if invariant_baseline is None:
            invariant_baseline = invariant_regions
            if any(not any(region) for region in invariant_regions):
                failed = True
                print(f"invariant_empty={name}", file=sys.stderr)
        elif invariant_regions != invariant_baseline:
            failed = True
            print(f"invariant_mismatch={name}", file=sys.stderr)
        png(args.images / f"{name}.png", data, width, height)
        if args.profile == "pi":
            physical = (args.captures / f"{name}-physical.rgb565").read_bytes()
            if len(physical) != 480 * 320 * 2:
                raise ValueError(f"{name}: mapped PiScreen capture has wrong extent")
            png(args.images / f"{name}-physical.png", physical, 480, 320)
        digest = hashlib.sha256(data).hexdigest()
        print(f"raster={name}\tbytes={len(data)}\tsha256={digest}")
        if args.references is None:
            continue
        reference = (args.references / f"{name}.rgb565").read_bytes()
        if data != reference:
            failed = True
            diff = bytearray(len(data))
            for offset in range(0, len(data), 2):
                if data[offset : offset + 2] != reference[offset : offset + 2]:
                    diff[offset : offset + 2] = b"\xf8\x00"
            png(args.images / f"{name}-diff.png", diff, width, height)
            print(f"raster_mismatch={name}", file=sys.stderr)
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
