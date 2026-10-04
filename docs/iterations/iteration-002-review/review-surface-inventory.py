"""Index reviewed owner boundaries and retained guard purposes; not a conformance test."""

import csv
from pathlib import Path
import re
import subprocess

root = Path.cwd()
out = root / "docs/iterations/iteration-002-review/evidence"
groups = {
    "05": "GiftUI GiftUIMacros GiftUIDynamicConveniences SignalAnalyzerDomain SignalAnalyzerData SignalAnalyzerPresentation SignalAnalyzerHost",
    "06": "GiftUISemanticCore GiftUITextResources GiftUIReferenceTextResources GiftUILayout GiftUIRenderCore GiftUIRenderLowering GiftUIDrawing",
    "07": "GiftUIExecution GiftUIObservableState GiftUIInteraction GiftUIRuntimeCore GiftUIRuntimeDynamic GiftUIRuntimeStatic",
    "08": "GiftUICapabilities GiftUIFailureCore GiftUIFailureExecution GiftUIFailureDiagnostics GiftUISurfaceCore GiftUIDisplayCore GiftUIRasterCore GiftUIBackendIntegration GiftUIPlatformRaspberryPi GiftUIHostConfiguration SignalAnalyzerTargetHost SignalAnalyzerPresetHarness SignalAnalyzerMacOSDynamic SignalAnalyzerMacOSStatic SignalAnalyzerNRF52840HostOracle SignalAnalyzerRaspberryPiARMv6",
}
steps = {name: step for step, names in groups.items() for name in names.split()}


def write(name, header, rows):
    with (out / name).open("w", newline="") as handle:
        writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
        writer.writerow(header)
        writer.writerows(rows)


rows = []
for target in csv.DictReader((out / "modules.tsv").open(), delimiter="\t"):
    name = target["module"]
    if name in steps:
        step, perspective = steps[name], "owner interfaces and representative production joins"
    elif target["type"] == "test":
        step, perspective = "09/11", "corpus role and automated hardware-free gate; not every test manually reviewed"
    elif name.endswith("Fixture"):
        step, perspective = "08/09", "contract failure adapter fixture; excluded from executable production closure"
    else:
        raise ValueError("Unassigned review target: " + name)
    rows.append([name, target["type"], target["path"], step, perspective])
assert len(rows) == 84
write("09-module-review.tsv", ["module", "type", "path", "step", "review_perspective"], rows)


def policy(path, expression):
    if "DIAGNOSTICS_CAPACITY" in expression:
        return "diagnostic storage selection", "retain bounded tuple capacities and conflicting-flag rejection"
    if "CAPABILITY_INSTRUMENTATION" in expression:
        return "instrumentation", "retain exclusion of counters from uninstrumented builds; consider separate realization"
    if "REFERENCE_" in expression:
        return "resource payload selection", "retain bitmap/outline exclusion and mutually exclusive configuration checks"
    if path.startswith("Sources/GiftUI/Canvas"):
        return "profile declaration", "retain Dynamic closure exclusion from Static public declaration; contract change required"
    if path.startswith("Sources/GiftUIRasterCore"):
        return "profile arithmetic", "retain Embedded division fallback and Dynamic specialization; require pixel and forbidden-symbol parity"
    if "Generated/" in path:
        return "native helper exclusion", "retain collection/helper exclusion from Embedded production; change generator and closure together"
    if "GIFTUI_NRF_EMBEDDED" in expression:
        return "embedded source selection", "file-level guards are source-selection candidates; preserve native rehearsal and Embedded closure"
    if "DT_NODE_HAS_PROP" in expression:
        return "board capability", "retain optional Devicetree backlight support"
    if "CONFIG_WATCHDOG" in expression:
        return "board configuration", "retain optional watchdog dependency"
    if "os(" in expression or "canImport(" in expression:
        return "platform selection", "file-level selection candidate where possible; retain OS APIs and native rehearsal distinction"
    raise ValueError((path, expression))


guards = []
tracked = subprocess.check_output(["git", "ls-files"], text=True).splitlines()
for path in tracked:
    if not (path.startswith("Sources/") and path.endswith(".swift")) and not (
        path.startswith("firmware/nrf52840/applications/signal-analyzer-static/src/") and path.endswith(".c")
    ):
        continue
    for line, text in enumerate((root / path).read_text().splitlines(), 1):
        match = re.match(r"\s*#(?:if|ifdef|ifndef)\s+(.+)", text)
        if match:
            category, reason = policy(path, match[1])
            guards.append([path, line, match[1], category, reason])
assert sum(path.endswith(".swift") for path, *_ in guards) == 59
assert sum(path.endswith(".c") for path, *_ in guards) == 5
write("09-source-guards.tsv", ["path", "line", "expression", "purpose", "disposition_and_validation"], guards)
print(f"Assigned {len(rows)} targets; classified {len(guards)} opening production guards")
