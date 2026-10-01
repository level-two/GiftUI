#!/usr/bin/env python3
"""Render recorded RGB565 frames and compare them with reviewed references."""

import argparse
import hashlib
import pathlib
import struct
import sys
import zlib

EXTENTS = {"pi": (240, 240), "nrf": (320, 240)}
INVARIANT_RECTS = {
    "pi": ((36, 4, 205, 34), (4, 75, 13, 185)),
    "nrf": ((52, 4, 272, 23), (52, 27, 266, 46)),
}
PLOT_RECTS = {"pi": (0, 72, 240, 203), "nrf": (0, 94, 320, 174)}
TRACE_BANDS = {
    "pi": ((76, 94), (106, 124), (136, 154), (166, 184)),
    "nrf": ((98, 110), (118, 130), (138, 150), (158, 170)),
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


def pixel_at(pixels, width, x, y):
    offset = (y * width + x) * 2
    return pixels[offset] << 8 | pixels[offset + 1]


def waveform_pixels_present(pixels, width, profile):
    left, top, right, bottom = PLOT_RECTS[profile]
    grid = 0x8410  # RGB565 gray
    trace = 0x07E0  # RGB565 green
    grid_columns = [
        x for x in range(left, right)
        if sum(pixel_at(pixels, width, x, y) == grid for y in range(top, bottom)) >= 30
    ]
    grid_lines = sum(
        index == 0 or x > grid_columns[index - 1] + 1
        for index, x in enumerate(grid_columns)
    )
    if grid_lines != 11:
        return False
    # Derive the plot columns from the rendered grid, rather than assuming
    # the old fixed-width Canvas position. Labels stay outside this interval.
    left, right = grid_columns[0], grid_columns[-1] + 1
    center_line = max(
        sum(pixel_at(pixels, width, x, y) == grid for x in range(left, right))
        for y in range(top, bottom)
    )
    trace_levels = True
    for band_top, band_bottom in TRACE_BANDS[profile]:
        rows = [
            y for y in range(band_top, band_bottom)
            if sum(pixel_at(pixels, width, x, y) == trace for x in range(left, right))
            >= 10
        ]
        if len(rows) < 2 or rows[-1] - rows[0] < 4:
            trace_levels = False
            break
    return grid_lines == 11 and center_line >= 80 and trace_levels


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
        if state == "running-four-traces" and not waveform_pixels_present(
            data, width, args.profile
        ):
            failed = True
            print(f"waveform_or_grid_missing={name}", file=sys.stderr)
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
