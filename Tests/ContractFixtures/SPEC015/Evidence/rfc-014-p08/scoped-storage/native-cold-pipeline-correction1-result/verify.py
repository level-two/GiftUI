#!/usr/bin/env python3
"""Offline integrity and failed-gate verification; executes no Swift workload."""

import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = next(p for p in HERE.parents if (p / ".git").exists())
MANIFEST = json.loads((HERE / "manifest.json").read_text())


def sha(data):
    return hashlib.sha256(data).hexdigest()


archive = HERE / "diagnostics.tar.gz"
assert sha(archive.read_bytes()) == MANIFEST["archive_sha256"]
with tarfile.open(archive) as tar:
    data = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
assert {n: sha(b) for n, b in data.items()} == MANIFEST["archive_members_sha256"]

relocations = data["diagnostic/counter-model-relocations.txt"].decode()
text = relocations.split("Relocation information (__TEXT,__text)", 1)[1].split(
    "Relocation information", 1
)[0]
relocs = {}
for line in text.splitlines():
    match = re.match(r"^([0-9a-f]{8})\s", line)
    if match:
        relocs.setdefault(int(match[1], 16), []).append(line)
for address in (0x1F44, 0x208C, 0x22DC, 0x28E4, 0x540B4, 0x54324, 0x54648):
    assert any("BR26" in row and "___swift_instantiateConcreteTypeFromMangledName" in row
               for row in relocs[address]), hex(address)
for address in (0x2720, 0x54874):
    assert any("BR26" in row and "0B6ScreenV15_giftUITraverse" in row
               for row in relocs[address]), hex(address)
symbols = json.loads(data["diagnostic/counter-model-symbols.json"])
assert any(s["address"] == 0x53E28 and "beginObservableCandidateAndExpandSemantics" in s["name"]
           for s in symbols)

symbol = "$s22P08CounterPresentation0B6ScreenV15_giftUITraverseyyqd__z6DomainQyd__Rsz6GiftUI01_H26UISemanticTraversalVisitorRd__Ri_d__Ri0_d__lF"


def body(sil):
    # Avoid matching an earlier unrelated SIL function through a greedy header.
    lines = sil.splitlines()
    first = next(i for i, line in enumerate(lines)
                 if line.startswith("sil ") and "@" + symbol + " :" in line)
    last = next(i for i in range(first + 1, len(lines))
                if lines[i].startswith("} // end sil function"))
    return "\n".join(lines[first:last + 1])


provider = body(data["diagnostic/P08CounterPresentation.sil"].decode())
consumer_sil = data["diagnostic/P08CounterRuntime.sil"].decode()
consumer = body(consumer_sil)
assert "[heuristic_always_inline]" in provider and "bb0" in provider
assert "[heuristic_always_inline]" in consumer and "bb0" not in consumer
assert "function_ref @" + symbol in consumer_sil

byte_counts = {}
for stem, expected in (("Bitmap", 1911), ("Outline", 13195)):
    path = f"Sources/GiftUIReferenceTextResources/Generated/Reference{stem}Payload.generated.swift"
    before = subprocess.check_output(["git", "show", "b0c057aa:" + path], cwd=ROOT).decode()
    after = data["compiled-source/" + path].decode()
    old = {int(m[1]): bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2}) as UInt8", m[2]))
           for m in re.finditer(r"static let glyph(\d+)(?:: \(\))? = \((.*?)\)", before, re.S)}
    new = {int(m[1]): bytes(int(x, 16) for x in re.findall(r"let byte\d+: UInt8 = 0x([0-9a-fA-F]{2})", m[2]))
           for m in re.finditer(r"private struct Glyph(\d+)Bytes \{(.*?)\}", after, re.S)}
    assert old and old == new, (stem, set(old) ^ set(new))
    assert sum(map(len, new.values())) == expected
    assert re.findall(r"case (\d+):", before) == re.findall(r"case (\d+):", after)
    byte_counts[stem] = expected
path = "Sources/GiftUIReferenceTextResources/Generated/generation-manifest.json"
before = json.loads(subprocess.check_output(["git", "show", "b0c057aa:" + path], cwd=ROOT))
after = json.loads(data["compiled-source/" + path])
before.pop("outputs")
after.pop("outputs")
assert before == after

for path, expected in MANIFEST["external_files_sha256"].items():
    assert sha((ROOT / path).read_bytes()) == expected, path
assert sha(subprocess.check_output(["git", "diff", "--", *sorted(MANIFEST["external_files_sha256"])],
                                   cwd=ROOT)) == MANIFEST["external_diff_sha256"]
assert MANIFEST["corrective_cycles_used"] == 1 and not MANIFEST["runtime_executed"]
print(json.dumps({"archive_members_verified": len(data), "all_ordered_payload_bytes_equal": byte_counts,
                  "actual_host_retained_generic_edge": "0x54874", "result": "codegen prerequisite FAIL",
                  "corrective_cycles_used": 1, "runtime_executed": False}, indent=2))
