#!/usr/bin/env python3
"""One native geometry build/run, with exact input hashes and invocation accounting.

Imports are removed solely to construct a disposable host geometry fixture.
This is not the supported separate-owner Embedded firmware build.
"""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUTPUT = ROOT / ".build/iteration-003/spike-068"
if sys.argv[1:]:
    if sys.argv[1:] not in [["--repair", "1"], ["--repair", "2"]]:
        raise SystemExit("Only --repair 1 or --repair 2 is accepted; each requires budget accounting.")
    OUTPUT = OUTPUT / ("repair-" + sys.argv[2])
OUTPUT.mkdir(parents=True, exist_ok=True)
RESULT = OUTPUT / "result.json"
if RESULT.exists():
    raise SystemExit("An attempt already exists; preserve it before an explicitly charged repair.")

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

cmake = ROOT / "firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt"
paths = list(dict.fromkeys(re.findall(
    r'"\$\{giftui_project_root\}/(Sources/[^"\n]+\.swift)"', cmake.read_text())))
assert len(paths) > 100
combined = OUTPUT / "Control.swift"
preset = ROOT / "firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift"
variant = re.search(r"^package enum StaticSignalAnalyzerNRFSemanticVariant[^\n]+\{.*?^\}",
                    preset.read_text(), re.M | re.S).group(0)
combined.write_text(variant + "\n" + "\n".join(
    "// " + path + "\n" + re.sub(r"^import [A-Za-z0-9_]+\n", "", (ROOT / path).read_text(), flags=re.M)
    for path in paths))
compiler = Path("/usr/bin/swiftc")
record = {
    "scope": "native generated-control geometry; not candidate, timing, or target safety",
    "source_commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
    "compiler": str(compiler),
    "compiler_version": subprocess.check_output([str(compiler), "--version"], text=True).strip(),
    "source_hashes": {path: digest(ROOT / path) for path in paths},
    "recipe_hashes": {str(path.relative_to(ROOT)): digest(path) for path in [cmake, preset, HERE / "Probe.swift", HERE / "run.py"]},
    "preset_fragment": variant,
    "combined_sha256": digest(combined),
    "invocations": [],
}

def save():
    RESULT.write_text(json.dumps(record, indent=2) + "\n")

def invoke(name, command):
    item = {"name": name, "command": command, "started_unix": time.time()}
    record["invocations"].append(item)
    save()
    with (OUTPUT / (name + ".log")).open("w") as log:
        proc = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, timeout=180)
    item.update(exit_code=proc.returncode, elapsed_seconds=time.time() - item["started_unix"],
                log_sha256=digest(OUTPUT / (name + ".log")))
    save()
    if proc.returncode:
        raise SystemExit(f"{name} failed; see {OUTPUT / (name + '.log')}")

binary = OUTPUT / "probe"
invoke("build", [str(compiler), "-Osize", "-whole-module-optimization", "-parse-as-library",
                 "-DGIFTUI_NRF_EMBEDDED", "-DGIFTUI_REFERENCE_BITMAP_ONLY", "-package-name", "GiftUI",
                 "-module-cache-path", str(OUTPUT / "module-cache"), str(combined),
                 str(HERE / "Probe.swift"), "-o", str(binary)])
record["binary_sha256"] = digest(binary)
invoke("run", [str(binary)])
lines = (OUTPUT / "run.log").read_text().splitlines()
fills = [list(map(int, line.split()[1:])) for line in lines if line.startswith("fill ")]
total = list(map(int, next(line for line in lines if line.startswith("total ")).split()[1:]))
assert len(fills) == total[0]
assert sum(width * height for _, _, width, height, _ in fills) == total[1]
assert all(width * height == area for _, _, width, height, area in fills)
overlay = ROOT / "firmware/nrf52840/applications/signal-analyzer-static/app.overlay"
header = ROOT / "firmware/nrf52840/applications/signal-analyzer-static/include/spi_tft.h"
display = re.search(r"giftui_spi_tft: display@0 \{(.*?)\};", overlay.read_text(), re.S).group(1)
hz = int(re.search(r"spi-max-frequency = <(\d+)>", display).group(1))
bpp = int(re.search(r"#define GIFTUI_SPI_TFT_BYTES_PER_PIXEL (\d+)U", header.read_text()).group(1))
record.update(
    transfer_input_hashes={str(path.relative_to(ROOT)): digest(path) for path in [overlay, header]},
    fill_rectangles=fills, fill_pixels=total[1], bytes_per_pixel=bpp, spi_max_hz=hz,
    mandatory_fill_bytes=total[1] * bpp,
    wire_lower_bound_ms=total[1] * bpp * 8 * 1000 / hz,
    gate="G3", gate_result="FAIL" if total[1] * bpp * 8 * 4 > hz else "not_refuted",
    exclusions=["glyph pixels", "Canvas strokes", "commands", "bus gaps", "CPU work"],
)
save()
print(json.dumps({key: record[key] for key in ["fill_pixels", "mandatory_fill_bytes", "spi_max_hz", "wire_lower_bound_ms", "gate_result"]}, indent=2))
